# dotfiles

tsutax26b's Dot Files

## Supported

- [ubuntu](https://ubuntu.com)
- [ubuntu on wsl](https://ubuntu.com/wsl)

## Installation

> [!NOTE] \
> If you're using WSL, please execute the following command in PowerShell.

```powershell
PS C:xxx/yyy > wsl --install Ubuntu-22.04
PS C:xxx/yyy > wsl
```

### main

```bash
bash <(curl -LSs https://raw.githubusercontent.com/tsutax26b/dotfiles/main/install.sh)
```

#### What does install.sh do?

- apply dotfiiles
- install [github cli](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)
- install [docker](https://matsuand.github.io/docs.docker.jp.onthefly/engine/install/ubuntu/#installation-methods) :whale:
- install [minikube](https://minikube.sigs.k8s.io/docs/start/) :anchor:
