## Xfind utility

`xfind` searches file contents outside Git repositories, where the more
powerful `xgrep` is unavailable. It requires at least one search term and uses
the same Boolean search model as `xgrep`.

```text
Usage:
  xfind [options] <term>...

Boolean terms:
  Terms are required by default and are combined with AND.
  and  Add following terms to the required group.
  or   Add following terms to a single OR group.
  not  Add following terms to a single excluded OR group.

Options:
  -d, --debug                 Print the command without running it.
      --no-debug              Disable debug mode set by .xfind.
  -h, --help                  Show the help message.
  -i, --ignore-case           Ignore case distinctions.
  -t, --include-type TYPE     Include a file extension.
  -T, --exclude-type TYPE     Exclude a file extension.
  -p, --include-path PATH     Include files beneath a directory.
  -P, --exclude-path PATH     Exclude files beneath a directory.
```

The `.git` and `node_modules` directories are excluded by default.
Like `xgrep`, `xfind` prints a blank line before search results and debug
output.

When writing search results to a terminal, filenames are magenta and their
separating colons are cyan. These added colors are disabled when output is
redirected, `NO_COLOR` is nonempty, or `TERM` is `dumb`.

### Searching content

Search all selected files for `foo`:

```bash
xfind foo
```

Additional terms filter the previous results, so this returns lines containing
both `foo` and `bar`:

```bash
xfind foo bar
```

Search terms are matched only against file contents. A term appearing in a file
or directory name does not satisfy the search.

Like `xgrep`, every search term is an extended regular expression. Quote terms
containing shell characters:

```bash
xfind 'error|warning'
xfind 'item-[0-9]+'
```

Searches are case-sensitive by default. Use `-i` or `--ignore-case` to match
regardless of letter case:

```bash
xfind -i error
```

Use the Boolean `not` operator to exclude matching terms. There is no separate
inverted-search option.

### Boolean searches

Terms begin in the required group. The operators switch the group used for all
following terms. This searches for `alpha`, either `beta` or `gamma`, and
neither `generated` nor `vendor`:

```bash
xfind alpha or beta gamma not generated vendor
```

This uses the following search logic:

```text
alpha AND (beta OR gamma) AND NOT (generated OR vendor)
```

Start with `or` for a pure OR search:

```bash
xfind or alpha beta
```

Use `and` to switch back to the required group:

```bash
xfind alpha or beta gamma and delta
```

To search for the literal words `and`, `or`, or `not`, prefix the word with one
or more dashes and place it after `--`:

```bash
xfind -- --and
```

Every part of the Boolean expression applies to one line. After filtering, a
final `grep` colors every positive search term in the resulting lines.

### File types

Lowercase `-t` includes file types and uppercase `-T` excludes them. Specify
extensions without a leading dot.

Search JavaScript files for `foo` while excluding JavaScript test files ending
in `.spec.js`:

```bash
xfind foo -t js -T spec.js
```

Options can be repeated. Include both Ruby and shell files:

```bash
xfind foo -t rb -t sh
```

### Paths

Lowercase `-p` includes a directory and uppercase `-P` excludes one.

Search only beneath `src` and `lib`:

```bash
xfind foo -p src -p lib
```

Search everywhere except beneath `spec`:

```bash
xfind foo -P spec
```

### Project defaults

If `.xfind` exists in the current directory, its whitespace-separated options
and terms are prepended to the command line. The file is intended to be committed
to source control so everyone working on a project shares the same defaults:

```text
-T min.js
-P vendor
-P tmp
```

### Debug output

Use `-d` to inspect the generated command without running it:

```console
$ xfind -d foo -t js -T spec.js
find . -type f \( -name \*.js \) \! -name \*.spec.js \! -path \*/.git/\* \! -path \*/node_modules/\* -print | sort | xargs grep -E --color=auto -H -- foo
```

### Maintenance

Behavior changes must update `tests/xfind_test.sh` in the same change. Boolean
changes must preserve its parity checks against `xgrep`. Keep the script
compatible with Bash 3.2 and with the standard `find`, `grep`, and `sort`
commands available on supported Linux and macOS systems.
