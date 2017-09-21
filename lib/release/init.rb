require_relative './base'

module Release

  class Init < Release::Base
    def valid?
      argv.size > 1
    end

    def help
      "release init version"
    end

    def execute
      subcommand, version, *extras = *argv

      validate_version_format version
      
      validate_current_branch_master
      git_pull current_branch

      validate_version_is_new version

      git_local_tag version

      git_push_tags

    end
  end

end
