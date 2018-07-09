export PATH=$HOME/.gem/ruby/2.4.0/bin:$PATH
export PATH=$HOME/.gem/ruby/2.5.0/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/c/scripts:$PATH

# check for resize after every command
shopt -s checkwinsize

# prompt
export PS1='\n \u@\h \w \n :3 '

# set ls colors
eval "$(dircolors ~/.dircolors.ansi-universal)"

# completion
source /usr/share/fzf/completion.bash
source /usr/share/fzf/key-bindings.bash

# functions
export OPSWORKS_SSH_KEY=~/.ssh/broadstripes/javier_opsworks

docker_rspec_last_screenshot () {
    docker exec passenger ls -At1 /app/log/capybara | head -n 1
}

docker_rspec_fetch_screenshot () {
    local LATEST_SCREENSHOT
    LATEST_SCREENSHOT=$(docker_rspec_last_screenshot)
    docker cp \
           passenger:/app/log/capybara/"$LATEST_SCREENSHOT" \
           /tmp/
    feh "/tmp/$LATEST_SCREENSHOT" &
}

docker_rspec () {
    docker exec -it -e RAILS_ENV='test' passenger bash -lc "xvfb-run rspec $1"
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga
}

docker_rake () {
    docker exec -it passenger bin/rake "$*"
}

find_spec_file () {
    find ~/broadstripes/crm/spec/ -type f -name '*spec.rb' -printf '%P\n' | fzf
}

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
alias ls='ls --color=always'

alias d=docker
alias dps='docker ps -a'

alias dc=docker-compose

alias dj='docker exec -it -e COLUMNS=$(tput cols) -e LINES=$(tput lines) passenger bash -l'
alias dfindspec='find_spec_file'
alias dspec='docker_rspec'
alias drake='docker exec -it passenger bin/rake'
alias drails='docker exec -it passenger bin/rails'
alias dsummon='docker_rspec_fetch_screenshot'
