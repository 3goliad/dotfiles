export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/c/scripts:$PATH
export PATH=$HOME/go/bin:$PATH

gem_user_dir=$(ruby -e 'print Gem.user_dir')
export PATH="$PATH:$gem_user_dir/bin"
export GEM_HOME=$gem_user_dir
unset gem_user_dir
