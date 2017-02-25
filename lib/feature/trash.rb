require_relative './base'

module Feature

  class Trash < Feature::Base
    def valid?
      argv.size == 2
    end

    def help
      "feature trash confirmation-branch"
    end

    def execute
      parts = parse_branch(current_branch)

      if argv.size == 2
        confirmation_branch = argv[1]
      else
        confirmation_branch = ''
      end

      standard_branch = parts[:standard]
      feature_branch  = current_branch

      error "missing confirmation of branch: #{feature_branch}" if confirmation_branch == ''
      error "confirmation branch does not match current branch: #{confirmation_branch} vs #{feature_branch}" if feature_branch != confirmation_branch
      error "invalid feature branch: #{feature_branch}" if standard_branches.include? feature_branch

      git_checkout standard_branch

      git_local_branch_trash feature_branch

      if remote_branch(feature_branch) != ""
        git_remote_branch_delete feature_branch
      end

      git_prune
    end
  end

end
