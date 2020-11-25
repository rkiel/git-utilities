require_relative './base'

module Release

  class Trash < Release::Base
    def valid?
      argv.size == 2
    end

    def help
      "release trash local-branch-confirmation"
    end

    def execute
      if argv.size == 2
        confirmation_branch = argv[1]
      else
        confirmation_branch = ''
      end

      release_branch  = current_branch

      error "Missing confirmation of branch: #{release_branch}" if confirmation_branch == ''
      error "Confirmation branch does not match current branch: #{confirmation_branch} vs #{release_branch}" if release_branch != confirmation_branch
      validate_current_branch_is_release

      git_checkout default_branch
      git_fetch_and_merge default_branch

      git_local_branch_trash release_branch

      if remote_branch(release_branch) != ""
        git_remote_branch_delete release_branch
      end

      git_prune
    end
  end

end
