# Usage: source /path/to/dotfiles/bash/profile.sh <user>

if [ "$#" -ne 1 ]; then
  printf 'usage: source /path/to/dotfiles/bash/profile.sh <user>\n' >&2
  return 2
fi

_git_utilities_profile_path=${BASH_SOURCE[0]}

if ! _git_utilities_profile_repo="$(
  CDPATH= cd "$(dirname "$_git_utilities_profile_path")/../.." 2>/dev/null && pwd -P
)"; then
  printf 'git-utilities profile: could not determine the repository path\n' >&2
  unset _git_utilities_profile_path _git_utilities_profile_repo
  return 1
fi

_git_utilities_profile_bin="$_git_utilities_profile_repo/bin/bash"
if [ ! -x "$_git_utilities_profile_bin/feature" ]; then
  printf 'git-utilities profile: feature is not executable in %s\n' \
    "$_git_utilities_profile_bin" >&2
  unset _git_utilities_profile_path _git_utilities_profile_repo
  unset _git_utilities_profile_bin
  return 1
fi

FEATURE_USER=$1
GIT_UTILITIES=$_git_utilities_profile_repo

case "${PATH-}" in
  "$_git_utilities_profile_bin"|"$_git_utilities_profile_bin":*)
    ;;
  *)
    PATH="$_git_utilities_profile_bin${PATH:+:$PATH}"
    ;;
esac

export FEATURE_USER GIT_UTILITIES PATH

unset _git_utilities_profile_path _git_utilities_profile_repo
unset _git_utilities_profile_bin
