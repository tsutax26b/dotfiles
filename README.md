# dotfiles

tsutax26b's Dot Files

## Supported

- [ubuntu](https://ubuntu.com)
- [ubuntu on wsl](https://ubuntu.com/wsl)

## Installation

### [Optional] Install WSL (Ubuntu Distribution) 

```powershell
PS C:xxx/yyy > wsl --list --online
...
PS C:xxx/yyy > wsl --install Ubuntu-{XX.XX}
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
