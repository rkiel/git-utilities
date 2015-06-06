require_relative './base'

module Feature

  class End < Feature::Base
    def valid?
      argv.size == 1
    end

    def help
      puts
      puts "USAGE: feature end"
      puts
      exit
    end

    def execute
      parts = parse_branch(current_branch)

      standard_branch = parts[:standard]
      feature_branch  = current_branch

      error "invalid feature branch: #{feature_branch}" if standard_branches.include? feature_branch

      git_checkout standard_branch

      if remote_branch(feature_branch) != ""
        git_remote_branch_delete feature_branch
      end

      git_local_branch_delete feature_branch

      git_prune
    end
  end

end

# fake change
