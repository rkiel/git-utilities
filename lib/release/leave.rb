require_relative './base'

module Release

  class Leave < Release::Base
    def valid?
      argv.size == 1
    end

    def help
      "release leave"
    end

    def execute
      validate_current_branch_is_release

      git_checkout 'master'
      git_fetch_and_merge current_branch

      git_local_branch_trash current_branch
    end
  end

end
