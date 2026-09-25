# Shared profile setup for Bash and Zsh.
#
# Usage: source /path/to/dotfiles/shared/profile.sh <user> <repository>

if [ "$#" -ne 2 ]; then
  printf 'git-utilities profile: internal usage error\n' >&2
  return 2
fi

_git_utilities_shared_user=$1
_git_utilities_shared_repo=$2
_git_utilities_shared_bin="$_git_utilities_shared_repo/bin"

if [ ! -x "$_git_utilities_shared_bin/feature" ]; then
  printf 'git-utilities profile: feature is not executable in %s\n' \
    "$_git_utilities_shared_bin" >&2
  unset _git_utilities_shared_user _git_utilities_shared_repo
  unset _git_utilities_shared_bin
  return 1
fi

FEATURE_USER=$_git_utilities_shared_user
GIT_UTILITIES=$_git_utilities_shared_repo

case "${PATH-}" in
  "$_git_utilities_shared_bin"|"$_git_utilities_shared_bin":*)
    ;;
  *)
    PATH="$_git_utilities_shared_bin${PATH:+:$PATH}"
    ;;
esac

export FEATURE_USER GIT_UTILITIES PATH

unset _git_utilities_shared_user _git_utilities_shared_repo
unset _git_utilities_shared_bin
