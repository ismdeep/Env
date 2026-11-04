# Env

## How to install oh-my-zsh ?

```
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh/
```


Edit `~/.zshrc`

```
#!/usr/bin/env bash

export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="ys"
plugins=(git zsh-autosuggestions)
source "${ZSH}/oh-my-zsh.sh"

# source /path/to/Env/rc
```