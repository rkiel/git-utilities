require_relative './base'

module Release

  class NewVersion < Release::Base
    def valid?
      argv.size > 1
    end

    def help
      "release #{subcommand_name} version"
    end

    def execute
      subcommand, version, *extras = *argv

      validate_version_format version

      validate_current_branch_master
      git_pull current_branch

      validate_version_exists version

      new_branch = increment_version(version)
      validate_release_branch_does_not_exist(new_branch)

      git_local_branch_create new_branch, "v#{version}"

      git_push new_branch
    end

    private

    def subcommand_name
      error "override"
    end

    def increment_version (version)
      error "override"
    end

  end

end
