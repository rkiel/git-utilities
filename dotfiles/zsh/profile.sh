# Usage: source /path/to/dotfiles/zsh/profile.sh <user>

if [ "$#" -ne 1 ]; then
  printf 'usage: source /path/to/dotfiles/zsh/profile.sh <user>\n' >&2
  return 2
fi

_git_utilities_profile_path=${(%):-%N}

if ! _git_utilities_profile_repo="$(
  CDPATH= cd "$(dirname "$_git_utilities_profile_path")/../.." 2>/dev/null && pwd -P
)"; then
  printf 'git-utilities profile: could not determine the repository path\n' >&2
  unset _git_utilities_profile_path _git_utilities_profile_repo
  return 1
fi

if ! source "$_git_utilities_profile_repo/dotfiles/shared/profile.sh" \
  "$1" "$_git_utilities_profile_repo"; then
  unset _git_utilities_profile_path _git_utilities_profile_repo
  return 1
fi

unset _git_utilities_profile_path _git_utilities_profile_repo
