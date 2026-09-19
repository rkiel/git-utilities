# Usage: source /path/to/dotfiles/zsh/rc.sh

alias a='feature add'
alias c='feature commit'
alias d='clear; git diff -w'
alias l='feature log'
alias m='feature merge'
alias pop="git stash pop --index"
alias pull="git pull"
alias push="git push"
alias r='feature rebase'
alias s='feature status'
alias stash="git stash save"
alias x='xgrep'

autoload -Uz compinit
compinit

function get_feature_commands()
{
  if (( CURRENT == 2 )); then
    local -a commands

    commands=("${(@f)$(feature tab "$PREFIX")}")
    if (( ${#commands[@]} > 0 )); then
      compadd -- "${commands[@]}"
    fi
  else
    _files
  fi
}

compdef get_feature_commands feature
