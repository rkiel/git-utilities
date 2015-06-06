module Shared

  module Runnable
    def run_cmd ( cmd, fallback_branch = current_branch )
      puts
      puts cmd
      success = system cmd
      unless success
        system "git checkout #{fallback_branch}"
        error "(see above)"
      end
      puts
    end

    def error ( msg )
      puts
      puts "ERROR: #{msg}"
      puts
      exit
    end

    def git_show_branches
      run_cmd "git branch"
    end

    def git_checkout ( branch )
      run_cmd "git checkout #{branch}"
    end

    def git_remote_branch_delete ( branch )
      run_cmd "git push origin :#{branch}"
    end

    def git_local_branch_delete ( branch )
      run_cmd "git branch -d #{branch}"
    end

    def git_local_branch_trash ( branch )
      run_cmd "git branch -D #{branch}"
    end

    def git_prune
      run_cmd "git remote prune origin"
    end

    def git_pull (branch)
      run_cmd "git pull origin #{branch}"
    end

    def git_merge (branch)
      run_cmd "git merge #{branch}"
    end

    def git_push (branch)
      run_cmd "git push origin #{branch}"
    end

    def git_rebase (branch)
      run_cmd "git rebase #{branch}"
    end

    def git_local_branch_create (branch)
      run_cmd "git checkout -b #{branch}"
    end

    def git_commit (message)
      run_cmd "git commit -m \"#{message}\""
    end
  end

end
