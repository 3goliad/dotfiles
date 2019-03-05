# -*- mode: sh -*-
export PATH=$HOME/.gem/ruby/2.4.0/bin:$PATH
export PATH=$HOME/.gem/ruby/2.5.0/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/c/scripts:$PATH

# check for resize after every command
shopt -s checkwinsize

# prompt
export PS1='\n \u@\h \w \n :3 '

# completion
source /usr/share/fzf/completion.bash
source /usr/share/fzf/key-bindings.bash

# functions
export OPSWORKS_SSH_KEY=~/.ssh/broadstripes/javier_opsworks

pacman_installed_packages() {
  comm -23 <(pacman -Qqent | sort) <(pacman -Qg | awk '{print $2}' | sort);
  pacman -Qqm;
}

recently_modified_files () {
  find . -mtime -365 -printf %T@ %p | sort -k1,1nr | head
}

daily_commits() {
  git log \
    --since=midnight \
    --author="$(git config --get user.email)" \
    --format=%s
}


# Aliases
alias ls='exa'

alias d=docker
alias dps='docker ps -a'

alias dc=docker-compose

alias cat=bat
