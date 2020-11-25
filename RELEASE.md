[<<back](README.md)

## Release

`release` is a command line utility to make working with releases easier.  Releases are built and managed using branches and tags.  

Official release versions are tagged using a simplified [Semantic Versioning](http://semver.org/) format.  The tags start with the letter `v` followed by MAJOR.MINOR.PATCH.

Before a release is tagged with a version, a release candidate branch can be created and used for development.  The intent of the release candidate branch is to be short-term support for multiple developers and deployment to test environments.  They are prefixed by `rc`.

### Usage

```bash
release create version
release finish
release help
release join version
release leave
release list
release start (major|minor|patch) from version [using main]
release tab [pattern]
release trash local-branch-confirmation
```

#### Create

Create an official release tag.

```bash
release create version
```

You must be on the default branch.  The latest code will be pulled from the default branch and a tag created for the last commit.  For example, the following command will create a `v1.0.0` tag.

```bash
git checkout <your-default-branch-name>
release create 1.0.0
```

#### Start

Create a shared, release candidate branch.

```bash
release start (major|minor|patch) from version [using your-default-branch-name]
```

The `version` specified must be an existing official release version.  The `major`, `minor`, and `patch` options will increment the new version number accordingly.  For example, to create a patch update, the following command will create a `rc1.0.1` release candidate branch.  If the optional `using <your-default-branch-name>` is not specified, the release candiate branch will be created from the version tag (e.g. `v1.0.0`).  Otherwise, the release candiate branch will be created from the default branch.  Also, if the repository contains a `package.json` file, the `version` property will automatically be set and committed.

```bash
git checkout <your-default-branch-name>
release start patch from 1.0.0
```
or

```bash
git checkout <your-default-branch-name>
release start patch from 1.0.0 from 
```

Once the shared release candidate branch has been created, use `feature` to create and manage personal feature branches.

#### Join

Join in on using a shared, release candidate branch that someone else has previously created using the `start` command.

```bash
release join version
```

The `version` specified must be an existing release candidate branch version.  A local tracking branch will be created.  For example, the following command will create `rc1.0.1` as a local tracking branch.

```bash
git checkout <your-default-branch-name>
release join 1.0.1
```

Once you have joined the shared release candidate branch, use `feature` to create and manage personal feature branches.

#### Leave

Stop using a shared, release candidate branch but leave it intact for others to continue using.

```bash
release leave
```

Your local tracking branch will be forcibly removed.  If there are any local changes on the branch, they will be lost.  For example, the following command will remove `rc1.0.1` as a local tracking branch.

```bash
git checkout rc1.0.1
release leave
```

#### Finish

Finish the release candidate and create an official release.

```bash
release finish
```

The latest code from the release candidate branch will be pulled and a tag created.  The shared release candidate branch will then be removed.  For example, the following command will create `v1.0.1` version tag and removed `rc1.0.1` branch.

```bash
git checkout rc1.0.1
release finish
```

#### List

Display a listing of the current version tags and release candidate branches.

```bash
release list
```

#### Trash

Throw away the release candidate.

```bash
release trash local-branch-confirmation
```

The shared release candidate branch will be forcibly removed and no version tag will be created.  The release candidate branch must be checked out and entered as the `local-branch-confirmation`.  For example, the following command will remove the `rc1.0.1` release candidate branch.

```branch
git checkout rc1.0.1
release trash rc1.0.1
```

#### Tab

Support `bash` tab completion.

```branch
release tab [pattern]
```

In your `.bashrc`, include the following function.

```bash
function get_release_commands()
{
  if [ -z $2 ] ; then
    COMPREPLY=(`release tab`)
  else
    COMPREPLY=(`release tab $2`)
  fi
}
```

In your `.bashrc`, associate your function with the `release` command.

```bash
complete -F get_release_commands release
```

Of course, this has already been done for you if, in your `.bashrc`, you include the following:

```bash
source ~/GitHub/rkiel/git-utilities/dotfiles/bashrc
```
