# Usage: source /path/to/dotfiles/bash/rc.sh
#
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

function get_feature_commands()
{
  local current command

  COMPREPLY=()
  if [ "$COMP_CWORD" -ne 1 ]; then
    return
  fi

  current="${COMP_WORDS[COMP_CWORD]}"
  while IFS= read -r command; do
    COMPREPLY[${#COMPREPLY[@]}]="$command"
  done < <(feature tab "$current")
}

complete -o bashdefault -o default -F get_feature_commands feature
