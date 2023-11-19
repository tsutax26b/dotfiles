#!/usr/bin/env bash

is_ubuntu() {
    grep '^NAME="Ubuntu"' /etc/os-release  >/dev/null 2>&1
}

is_wsl() {
    uname -a | grep -i 'wsl'
}

download_dotfiles() {
    if [ -d "${dotfiles_path}" ]; then
        echo "already exists: ${dotfiles_path}"
        local yn
        read -rp 'Do you want to continue re-download tsutax26b/dotfiles the installation ? (y/N):' yn
        if [ "${yn}" != 'y' ]; then
            echo "[NOTE] The installation was canceled"
            exit 1
        fi
        echo "Pull latest tsutax26b/dotfiles to '${dotfiles_path}' ... "
        git -C "${dotfiles_path}" pull origin main
    else
        echo "Downloading tsutax26b/dotfiles to '${dotfiles_path}' ... "
        git clone https://github.com/tsutax26b/dotfiles.git "${dotfiles_path}"
    fi
}

backup_dotfiles() {
    local yn
    read -rp 'Do you want to backup configs ? (y/N):' yn
    if [ "${yn}" != 'y' ]; then
        echo "[NOTE] The backup step was skipped"
        return 0
    fi
    targets=(
        ".bash_profile"
        ".bashrc"
        ".gitconfig"
    )
    local -r backup_datetime="$(date +%Y%m%d_%H%M%S)"
    local -r destination_dir="${HOME}/dotfiles_backup_${backup_datetime}"
    local -r source_dir="${HOME}"
    mkdir "${destination_dir}"

    for target in "${targets[@]}"; do
        if [ -f "${source_dir}/${target}" ]; then
            cp "${source_dir}/${target}" "${destination_dir}/"
            echo "[INFO] cp ${source_dir}/${target} to ${destination_dir}/"
        else
            echo "[INFO] not found ${source_dir}/${target}"
        fi
    done
}

apply_dotfiles() {
    targets=(
        ".bash_profile"
        ".bashrc"
        ".gitconfig"
    )
    local -r destination_dir="${HOME}"
    local -r source_dir="${dotfiles_path}"
    for target in "${targets[@]}"; do
        ln -fnsv "${source_dir}/${target}" "${destination_dir}/${target}"
    done
    source "${HOME}/.bash_profile"
}


install_uitilities() {
    sudo apt update && sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        git \
        make \
        tree \
        zip unzip
    if is_wsl; then
        sudo apt install wslu
    fi
}

install_github_cli() {
    if command -v gh &> /dev/null; then
        echo "[INFO] gh cli is already installed."
        return 0
    fi
    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
    type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y \
    && gh auth login
}

install_docker() {
    if command -v docker &> /dev/null; then
        echo "[INFO] docker is already installed."
        return 0
    fi
    # https://matsuand.github.io/docs.docker.jp.onthefly/engine/install/ubuntu/#installation-methods
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

install_minikube() {
    if command -v minikube &> /dev/null; then
        echo "[INFO] minikube is already installed."
        return 0
    fi
    # https://minikube.sigs.k8s.io/docs/start/
    if [ "$(uname -m)" = "x86_64" ]; then
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
        minikube start
    elif [ "$(uname -m)" = "arm64" ]; then
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
        sudo install minikube-linux-arm64 /usr/local/bin/minikube
        rm minikube-linux-arm64
        minikube start
    else
        echo "[ERR] This setup script is for arm64 and x86_64 architectures only / uname -m $(uname -m)"
        echo "      Please install minikube manually."
        echo "      https://minikube.sigs.k8s.io/docs/start/"
    fi
}

main() {
    if ! is_ubuntu; then
        echo "[ERR] This script supports Ubuntu only."
        exit 1
    fi
    local -r dotfiles_path="$(realpath "${1:-"${HOME}/dotfiles"}")"
    install_uitilities
    download_dotfiles
    backup_dotfiles
    apply_dotfiles
    install_github_cli
    install_docker
    install_minikube
    source "${HOME}/.bash_profile"
}

main "$@"
