GIT_COLOR_OPTIONS=()
GIT_ARGUMENTS=()
GIT_PATHS=()

if [ -n "${NO_COLOR:-}" ] || [ "${TERM:-}" = 'dumb' ]; then
  GIT_COLOR_OPTIONS=(--no-color)
fi

build_git_paths() {
  local i j path type value
  local -a included_paths=()
  local -a excluded_paths=()

  for path in "${INCLUDE_PATHS[@]}"; do
    included_paths+=(":(glob)**/$path/**")
  done
  for type in "${INCLUDE_TYPES[@]}"; do
    included_paths+=(":*.$type")
  done
  for path in "${EXCLUDE_PATHS[@]}"; do
    excluded_paths+=(":(exclude,glob)**/$path/**")
  done
  for type in "${EXCLUDE_TYPES[@]}"; do
    excluded_paths+=(":!*.$type")
  done

  if [ "${#excluded_paths[@]}" -gt 0 ] && [ "${#included_paths[@]}" -eq 0 ]; then
    GIT_PATHS=(. "${excluded_paths[@]}")
  else
    GIT_PATHS=("${included_paths[@]}" "${excluded_paths[@]}")
  fi

  if [ "${#GIT_PATHS[@]}" -eq 0 ]; then
    GIT_PATHS=(.)
  fi

  for ((i = 1; i < ${#GIT_PATHS[@]}; i++)); do
    value="${GIT_PATHS[i]}"
    j="$i"
    while [ "$j" -gt 0 ] && [[ "${GIT_PATHS[j - 1]}" > "$value" ]]; do
      GIT_PATHS[j]="${GIT_PATHS[j - 1]}"
      j=$((j - 1))
    done
    GIT_PATHS[j]="$value"
  done
}

append_git_and() {
  if [ "$GIT_EXPRESSION_COUNT" -gt 0 ]; then
    GIT_ARGUMENTS+=(--and)
  fi
}

append_git_pattern() {
  local pattern="$1"

  append_git_and
  GIT_ARGUMENTS+=(-e "$pattern")
  GIT_EXPRESSION_COUNT=$((GIT_EXPRESSION_COUNT + 1))
}

append_git_or_group() {
  local negate="$1"
  local first=true pattern
  shift

  [ "$#" -gt 0 ] || return 0

  append_git_and
  if $negate; then
    GIT_ARGUMENTS+=(--not)
  fi
  GIT_ARGUMENTS+=("(")

  for pattern in "$@"; do
    if $first; then
      first=false
    else
      GIT_ARGUMENTS+=(--or)
    fi
    GIT_ARGUMENTS+=(-e "$pattern")
  done

  GIT_ARGUMENTS+=(")")
  GIT_EXPRESSION_COUNT=$((GIT_EXPRESSION_COUNT + 1))
}

build_engine_arguments() {
  local pattern
  local -a color_options=("${GIT_COLOR_OPTIONS[@]}")

  build_git_paths
  if $USE_FZF; then
    color_options=(--no-color)
  fi

  GIT_ARGUMENTS=(-E -I "${color_options[@]}")
  $IGNORE_CASE && GIT_ARGUMENTS+=(-i)
  $FILES_WITH_MATCHES && GIT_ARGUMENTS+=(-l)
  GIT_EXPRESSION_COUNT=0

  for pattern in "${AND_TERMS[@]}"; do
    append_git_pattern "$pattern"
  done
  append_git_or_group false "${OR_TERMS[@]}"
  append_git_or_group true "${NOT_TERMS[@]}"

  GIT_ARGUMENTS+=(-- "${GIT_PATHS[@]}")
}

print_engine_command() {
  local argument

  printf 'git grep'
  for argument in "${GIT_ARGUMENTS[@]}"; do
    printf ' %q' "$argument"
  done
}

run_engine() {
  command git grep "${GIT_ARGUMENTS[@]}"
}
