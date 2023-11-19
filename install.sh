#!/bin/bash

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
        read -rp 'Do you continue re-download tsutax26b/dotfiles the installation ? (y/N)' yn
        if [ "${yn}" != 'y' ]; then
            echo "The installation was canceled"
            exit 1
        fi
        rm -rf "${dotfiles_path}"
        echo "Pull latest tsutax26b/dotfiles to '${dotfiles_path}' ... "
        git pull -C origin main "${dotfiles_path}"
    else
        echo "Downloading tsutax26b/dotfiles to '${dotfiles_path}' ... "
        git clone https://github.com/tsutax26b/dotfiles.git "${dotfiles_path}"
    fi
}

backup_dotfiles() {
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
        ln -fnsv "${destination_dir}/${target}" "${source_dir}/${target}" 
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
    if witch gh; then
        echo "[INFO] gh cli is already installed."
        exit 0 
    fi
    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
    type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
}

install_docker() {
    if which docker; then
        echo "[INFO] docker is already installed."
        exit 0
    fi
    # # https://matsuand.github.io/docs.docker.jp.onthefly/engine/install/ubuntu/#installation-methods
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
}

main() {
    if ! is_ubuntu; then
        echo "[ERR] This script supports Ubuntu only."
        exit 1
    fi
    local -r dotfiles_path="$(realpath "${1:-"${HOME}/dotfiles"}")"
    echo
    install_uitilities
    download_dotfiles
    backup_dotfiles
    apply_dotfiles
    install_github_cli
    gh auth login
    install_docker    
}

main "$@"