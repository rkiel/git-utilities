## Xfind utility

`xfind` searches files outside Git repositories, where the more powerful
`xgrep` is unavailable. With no search terms it lists matching files. With one
or more terms it searches their contents.

```text
Usage:
  xfind [options] [<term>...]

Options:
  -d, --debug                 Print the command without running it.
      --no-debug              Disable debug mode set by .xfind.
  -h, --help                  Show the help message.
  -n, -t, --include-type TYPE Include a file extension.
  -N, -T, --exclude-type TYPE Exclude a file extension.
  -p, --include-path PATH     Include files beneath a directory.
  -P, --exclude-path PATH     Exclude files beneath a directory.
```

The `.git` and `node_modules` directories are excluded by default.
Like `xgrep`, `xfind` prints a blank line before listings, search results, and
debug output.

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

Unlike `xgrep`, `xfind` does not provide `or` and `not` Boolean groups. Each term
is passed through another `grep` and therefore further narrows the output. After
filtering, a final `grep` colors every search term in the resulting lines.

### File types

Lowercase options include file types and uppercase options exclude them. The
`-t` and `-T` options are convenience aliases for the original `-n` and `-N`
options. Specify extensions without a leading dot.

Search JavaScript files for `foo` while excluding JavaScript test files ending
in `.spec.js`:

```bash
xfind foo -t js -T spec.js
```

The equivalent command using the original option names is:

```bash
xfind foo -n js -N spec.js
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

### Listing files

Omit search terms to list selected files in sorted order:

```bash
xfind -t js -T spec.js
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
find . -type f \( -name \*.js \) \! -name \*.spec.js \! -path \*/.git/\* \! -path \*/node_modules/\* -print | sort | xargs grep --color=auto -H -- foo
```

### Maintenance

Behavior changes must update `tests/xfind_test.sh` in the same change. Keep the
script compatible with Bash 3.2 and with the standard `find`, `grep`, and `sort`
commands available on supported Linux and macOS systems.
