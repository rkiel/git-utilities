require_relative './base'

module Feature

  class Rebase < Feature::Base
    def valid?
      argv.size == 1
    end

    def help
      puts
      puts "USAGE: feature rebase"
      puts
      exit
    end

    def execute
      parts = parse_branch(current_branch)

      standard_branch = parts[:standard]
      feature_branch  = current_branch
      remote_branch   = remote_branch(feature_branch)

      error "USAGE: feature rebase" unless standard_branch
      error "invalid feature branch: #{feature_branch}" if standard_branches.include? feature_branch

      run_cmd "git checkout #{standard_branch}"
      run_cmd "git pull origin #{standard_branch}"
      run_cmd "git checkout #{feature_branch}"
      run_cmd "git rebase #{standard_branch}"

      if remote_branch != ""
        run_cmd "git push origin :#{feature_branch}"
      end

      run_cmd "git push origin #{feature_branch}"
    end
  end

end
