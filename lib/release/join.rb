require_relative './base'

module Release

  class Join < Release::Base
    def valid?
      argv.size == 2
    end

    def help
      "release join version"
    end

    def execute
      subcommand, version = *argv

      validate_current_branch_master
      git_fetch_and_merge current_branch

      git_checkout_track release_branch_from_version(version)
    end
  end

end
