# -*- mode: sh -*-

# check for resize after every command
shopt -s checkwinsize

# prompt
export PS1='\n \u@\h \w \n :3 '

# completion
source /usr/share/fzf/completion.bash
source /usr/share/fzf/key-bindings.bash

# enable z (jumpy)
[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

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

export CLUSTER_SSH_KEY=$HOME/.ssh/broadstripes/Harbinger.pem

source /usr/share/chruby/chruby.sh

# Aliases
alias ls='exa'
alias d=docker
alias dc=docker-compose
alias cat=bat
