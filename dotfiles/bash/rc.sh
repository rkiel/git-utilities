# Usage: source /path/to/dotfiles/bash/rc.sh
#
source "$(dirname "${BASH_SOURCE[0]}")/../shared/aliases.sh" || return

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
