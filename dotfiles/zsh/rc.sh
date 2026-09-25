# Usage: source /path/to/dotfiles/zsh/rc.sh

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
