# Bash Options

export OPSWORKS_SSH_KEY=~/.ssh/broadstripes/javier_opsworks

## Check for resize after every command
shopt -s checkwinsize

## Prompt
export PS1='\n \u@\h \w \n :3 '

# Set ls colors

eval "$(dircolors ~/.dircolors.ansi-universal)"

# Completion

source /usr/share/fzf/completion.bash
source /usr/share/fzf/key-bindings.bash

# Functions

docker_rspec_last_screenshot () {
    docker exec passenger ls -At1 /app/tmp/capybara | head -n 1
}

docker_rspec_fetch_screenshot () {
    local LATEST_SCREENSHOT
    LATEST_SCREENSHOT=$(docker_rspec_last_screenshot)
    docker cp \
           passenger:/app/tmp/capybara/"$LATEST_SCREENSHOT" \
           /tmp/
    feh "/tmp/$LATEST_SCREENSHOT" &
}

docker_rspec () {
    docker exec -it passenger xvfb-run bundle exec rspec "$1"
}

docker_bundle_exec () {
    docker exec -it passenger bundle exec rake "$*"
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

minikube_docker() {
    minikube docker-env | awk '/^export / {sub(/export /,""); printf "%s ",$0} END {printf "docker"}'
}

# Aliases
alias ls='ls --color=always'

alias d=docker
alias dps='docker ps -a'

alias dc=docker-compose

alias dspec='docker_rspec'
alias dfindspec='find_spec_file'
alias dbundlerun='docker exec -it passenger bundle exec'
alias drake='dbundlerun rake'
alias drails='dbundlerun rails'
alias dsummon='docker_rspec_fetch_screenshot'

alias md='eval "$(minikube_docker)"'
