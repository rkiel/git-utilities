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

      new_version = increment_version(version)
      validate_version_does_not_exist new_version
      validate_release_branch_does_not_exist(release_branch_from_version(new_version))

      git_local_branch_create release_branch_from_version(new_version), release_tag_from_version(version)

      git_push release_branch_from_version(new_version)
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
