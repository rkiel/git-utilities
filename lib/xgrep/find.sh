FIND_FILENAME_COLOR=''
FIND_SEPARATOR_COLOR=''
FIND_COLOR_RESET=''
FIND_GREP_COLOR_MODE=auto
FIND_GREP_OPTIONS=(-E -I)
FIND_HIGHLIGHT_TERMS=("${AND_TERMS[@]}" "${OR_TERMS[@]}")
FIND_ARGUMENTS=()
EXCLUDE_PATHS=(.git node_modules "${EXCLUDE_PATHS[@]}")

$IGNORE_CASE && FIND_GREP_OPTIONS+=(-i)

if [ -n "${NO_COLOR:-}" ] || [ "${TERM:-}" = 'dumb' ]; then
  FIND_GREP_COLOR_MODE=never
elif $USE_PAGER; then
  FIND_GREP_COLOR_MODE=always
  FIND_FILENAME_COLOR=$'\033[35m'
  FIND_SEPARATOR_COLOR=$'\033[36m'
  FIND_COLOR_RESET=$'\033[0m'
elif [ -t 1 ]; then
  FIND_FILENAME_COLOR=$'\033[35m'
  FIND_SEPARATOR_COLOR=$'\033[36m'
  FIND_COLOR_RESET=$'\033[0m'
fi

find_is_simple_search() {
  [ "${#AND_TERMS[@]}" -eq 1 ] &&
    [ "${#OR_TERMS[@]}" -eq 0 ] &&
    [ "${#NOT_TERMS[@]}" -eq 0 ]
}

append_find_include_group() {
  local predicate="$1"
  local prefix="$2"
  shift 2

  local first=true value

  [ "$#" -gt 0 ] || return 0

  FIND_ARGUMENTS+=("(")
  for value in "$@"; do
    if $first; then
      first=false
    else
      FIND_ARGUMENTS+=(-o)
    fi
    FIND_ARGUMENTS+=("$predicate" "${prefix}${value}")
  done
  FIND_ARGUMENTS+=(")")
}

append_find_exclusions() {
  local predicate="$1"
  local prefix="$2"
  shift 2

  local value

  for value in "$@"; do
    FIND_ARGUMENTS+=(! "$predicate" "${prefix}${value}")
  done
}

build_engine_arguments() {
  local path

  FIND_ARGUMENTS=(. -type f)

  append_find_include_group -name '*.' "${INCLUDE_TYPES[@]}"
  append_find_exclusions -name '*.' "${EXCLUDE_TYPES[@]}"

  if [ "${#INCLUDE_PATHS[@]}" -gt 0 ]; then
    FIND_ARGUMENTS+=("(")
    for path in "${INCLUDE_PATHS[@]}"; do
      if [ "${FIND_ARGUMENTS[${#FIND_ARGUMENTS[@]} - 1]}" != "(" ]; then
        FIND_ARGUMENTS+=(-o)
      fi
      FIND_ARGUMENTS+=(-path "*/$path/*")
    done
    FIND_ARGUMENTS+=(")")
  fi

  append_find_exclusions -path '*/' "${EXCLUDE_PATHS[@]/%//\*}"
  FIND_ARGUMENTS+=(-print)
}

print_find_argument() {
  printf ' %q' "$1"
}

print_find_grep_command() {
  local option

  printf 'grep'
  for option in "${FIND_GREP_OPTIONS[@]}"; do
    print_find_argument "$option"
  done
}

print_find_grep_group() {
  local invert="$1"
  local color="$2"
  local term
  shift 2

  printf ' | '
  print_find_grep_command
  $invert && printf ' -v'
  $color && printf ' --color=%s' "$FIND_GREP_COLOR_MODE"
  for term in "$@"; do
    printf ' -e'
    print_find_argument "$term"
  done
}

print_engine_command() {
  local argument index

  printf 'find'
  for argument in "${FIND_ARGUMENTS[@]}"; do
    print_find_argument "$argument"
  done
  printf ' | sort'

  if find_is_simple_search; then
    printf ' | xargs '
    print_find_grep_command
    if $FILES_WITH_MATCHES; then
      printf ' -l --'
    else
      printf ' --color=%s -H --' "$FIND_GREP_COLOR_MODE"
    fi
    print_find_argument "${AND_TERMS[0]}"
  else
    printf ' | while IFS= read -r file; do file="${file#./}"; '
    $FILES_WITH_MATCHES && printf 'if '
    if [ "${#AND_TERMS[@]}" -gt 0 ]; then
      print_find_grep_command
      printf ' --'
      print_find_argument "${AND_TERMS[0]}"
      printf ' < "$file"'
      for ((index = 1; index < ${#AND_TERMS[@]}; index++)); do
        printf ' | '
        print_find_grep_command
        printf ' --'
        print_find_argument "${AND_TERMS[index]}"
      done
    else
      printf 'cat < "$file"'
    fi
    [ "${#OR_TERMS[@]}" -eq 0 ] ||
      print_find_grep_group false false "${OR_TERMS[@]}"
    [ "${#NOT_TERMS[@]}" -eq 0 ] ||
      print_find_grep_group true false "${NOT_TERMS[@]}"
    if $FILES_WITH_MATCHES; then
      printf ' > /dev/null; then printf "%%s\\n" "$file"; fi; done'
    else
      printf ' | while IFS= read -r line; do printf "%%s:%%s\\n" "$file" "$line"; done; done'
      [ "${#FIND_HIGHLIGHT_TERMS[@]}" -eq 0 ] ||
        print_find_grep_group false true "${FIND_HIGHLIGHT_TERMS[@]}"
    fi
  fi
}

find_grep_batch() {
  local -a arguments=(grep "${FIND_GREP_OPTIONS[@]}")

  if $FILES_WITH_MATCHES; then
    arguments+=(-l)
  else
    arguments+=(--color="$FIND_GREP_COLOR_MODE" -H)
  fi
  arguments+=(-- "${AND_TERMS[0]}" "${FILE_BATCH[@]}")

  command "${arguments[@]}"
}

find_grep_sorted_files() {
  local file status
  local matched=false
  local -a FILE_BATCH=()

  while IFS= read -r file; do
    file="${file#./}"
    FILE_BATCH+=("$file")
    if [ "${#FILE_BATCH[@]}" -eq 100 ]; then
      if find_grep_batch; then
        matched=true
      else
        status=$?
        [ "$status" -eq 1 ] || return "$status"
      fi
      FILE_BATCH=()
    fi
  done < <(command find "${FIND_ARGUMENTS[@]}" | command sort)

  if [ "${#FILE_BATCH[@]}" -gt 0 ]; then
    if find_grep_batch; then
      matched=true
    else
      status=$?
      [ "$status" -eq 1 ] || return "$status"
    fi
  fi

  $matched
}

filter_find_and_terms() {
  local file="$1"
  local index="$2"

  if [ "$index" -eq 0 ]; then
    command grep "${FIND_GREP_OPTIONS[@]}" -- "${AND_TERMS[0]}" < "$file"
  else
    filter_find_and_terms "$file" "$((index - 1))" |
      command grep "${FIND_GREP_OPTIONS[@]}" -- "${AND_TERMS[index]}"
  fi
}

find_grep_group() {
  local invert="$1"
  local term
  local -a arguments=(grep "${FIND_GREP_OPTIONS[@]}")
  shift

  $invert && arguments+=(-v)
  for term in "$@"; do
    arguments+=(-e "$term")
  done

  command "${arguments[@]}"
}

filter_find_and_stage() {
  local file="$1"

  if [ "${#AND_TERMS[@]}" -gt 0 ]; then
    filter_find_and_terms "$file" "$((${#AND_TERMS[@]} - 1))"
  else
    command cat < "$file"
  fi
}

filter_find_or_stage() {
  local file="$1"

  if [ "${#OR_TERMS[@]}" -gt 0 ]; then
    filter_find_and_stage "$file" | find_grep_group false "${OR_TERMS[@]}"
  else
    filter_find_and_stage "$file"
  fi
}

filter_find_file() {
  local file="$1"

  if [ "${#NOT_TERMS[@]}" -gt 0 ]; then
    filter_find_or_stage "$file" | find_grep_group true "${NOT_TERMS[@]}"
  else
    filter_find_or_stage "$file"
  fi
}

prefix_find_lines() {
  local file="$1"
  local line

  while IFS= read -r line || [ -n "$line" ]; do
    printf '%s%s%s:%s%s\n' \
      "$FIND_FILENAME_COLOR" "$file" "$FIND_SEPARATOR_COLOR" \
      "$FIND_COLOR_RESET" "$line"
  done
}

find_grep_multiple_files() {
  local file status
  local matched=false

  while IFS= read -r file; do
    file="${file#./}"
    if filter_find_file "$file" | prefix_find_lines "$file"; then
      matched=true
    else
      status=$?
      [ "$status" -eq 1 ] || return "$status"
    fi
  done < <(command find "${FIND_ARGUMENTS[@]}" | command sort)

  $matched
}

list_find_matching_files() {
  local file status
  local matched=false

  while IFS= read -r file; do
    file="${file#./}"
    if filter_find_file "$file" >/dev/null; then
      printf '%s\n' "$file"
      matched=true
    else
      status=$?
      [ "$status" -eq 1 ] || return "$status"
    fi
  done < <(command find "${FIND_ARGUMENTS[@]}" | command sort)

  $matched
}

highlight_find_results() {
  local term
  local -a arguments=(grep "${FIND_GREP_OPTIONS[@]}" --color="$FIND_GREP_COLOR_MODE")

  for term in "${FIND_HIGHLIGHT_TERMS[@]}"; do
    arguments+=(-e "$term")
  done

  command "${arguments[@]}"
}

run_engine() {
  if find_is_simple_search; then
    find_grep_sorted_files
  elif $FILES_WITH_MATCHES; then
    list_find_matching_files
  elif [ "${#FIND_HIGHLIGHT_TERMS[@]}" -gt 0 ]; then
    find_grep_multiple_files | highlight_find_results
  else
    find_grep_multiple_files
  fi
}
