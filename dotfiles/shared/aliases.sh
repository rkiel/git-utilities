# Optional shared aliases and functions for Bash and zsh.

alias a='feature add'
alias c='feature commit'
alias d='clear; git diff -w'
alias l='feature log'
alias m='feature merge'
alias pop='git stash pop --index'
alias pull='git pull'
alias push='git push'
alias r='feature rebase'
alias s='feature status'
alias stash='git stash save'
alias x='xgrep'

ssh-start() {
  local ssh_status=0

  ssh-add -l >/dev/null 2>&1 || ssh_status=$?

  case "$ssh_status" in
    0)
      printf '%s\n' 'SSH key is already loaded.'
      ;;
    1)
      ssh-add "$HOME/.ssh/id_ed25519"
      ;;
    *)
      eval "$(ssh-agent -s)" && ssh-add "$HOME/.ssh/id_ed25519"
      ;;
  esac
}
