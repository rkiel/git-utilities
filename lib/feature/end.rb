require_relative './base'

module Feature

  class End < Feature::Base
    def execute
      error "USAGE: feature end" unless argv.size == 1

      parts = parse_branch(current_branch)

      standard_branch = parts[:standard]
      feature_branch  = current_branch

      error "invalid feature branch: #{feature_branch}" if standard_branches.include? feature_branch

      run_cmd "git checkout #{standard_branch}"

      if remote_branch(feature_branch) != ""
        run_cmd "git push origin :#{feature_branch}"
      end

      run_cmd "git branch -D #{feature_branch}"

      run_cmd "git remote prune origin"
    end
  end

end
