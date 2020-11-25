require_relative './base'

module Release

  class Create < Release::Base
    def valid?
      argv.size == 2
    end

    def help
      "release create version"
    end

    def execute
      subcommand, version, *extras = *argv

      validate_version_format version

      validate_current_branch_default
      git_fetch_and_merge current_branch

      validate_version_is_new version

      update_package_json version, version

      git_local_tag release_tag_from_version(version)

      git_push current_branch
      git_push_tags

    end
  end

end
