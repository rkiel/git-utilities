require_relative './base'

module Feature

  class Merge < Feature::Base
    def valid?
      [1].include? argv.size
    end

    def help
      "feature merge"
    end

    def execute
      parts = parse_branch(current_branch)

      standard_branch = parts[:standard]
      feature_branch  = current_branch
      remote_branch   = remote_branch(feature_branch)

      if argv.size == 2
        merge_to_branch = argv[1]
      elsif argv.size == 1
        merge_to_branch = parts[:standard]
      end

      error "invalid branch: #{merge_to_branch}" unless standard_branches.include? merge_to_branch or merge_to_branch =~ /\d+\.\d+\.\d+/

      # should match rebase
      git_fetch
      git_checkout standard_branch
      git_merge ['origin', standard_branch].join('/')
      git_checkout feature_branch

      git_rebase ['origin', standard_branch].join('/')
      if remote_branch != ""
        git_remote_branch_delete feature_branch
      end
      git_push feature_branch

      git_checkout merge_to_branch
      git_merge    feature_branch
      git_push     merge_to_branch
      git_push_tags
      git_checkout feature_branch
    end
  end

end
