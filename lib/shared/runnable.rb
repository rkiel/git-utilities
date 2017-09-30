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

    def git_local_tag ( tag )
      run_cmd "git tag -a '#{tag}' -m '#{tag}'"
    end

    def git_local_list_tags (release_tag_prefix)
      `git tag -l '#{release_tag_prefix}*'`.strip.split(/\s+/).sort
    end

    def git_local_list_branches (release_branch_prefix)
      `git branch -a|grep 'remotes/origin/rc'`.strip.split(/\s+/).map {|x| x.sub('remotes/origin/','')}.sort
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

    def git_push_tags
      run_cmd "git push origin --tags"
    end

    def git_push_upstream (branch)
      run_cmd "git push --set-upstream origin #{branch}"
    end

    def git_rebase (branch)
      run_cmd "git rebase #{branch}"
    end

    def git_local_branch_create (branch, commit='')
      run_cmd "git checkout -b #{branch} #{commit}"
    end

    def git_commit (message, force = false)
      message = force ? message+' (no-verify)' : message
      message = '"' + message + '"'
      verify = force ? '--no-verify' : ''
      cmd = ['git','commit','-m', message, verify].join(' ');
      run_cmd cmd
    end
  end

end
