require 'json'

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

    def update_package_json (version, message)
      if File.exist? 'package.json'
        package_json = File.read('package.json')
        json = JSON.parse(package_json)
        json['version'] = version
        File.write('package.json', JSON.pretty_generate(json))
        git_add 'package.json'
        git_commit message, true
      end
    end

    def package_json_version (default_value)
      if File.exist? 'package.json'
        package_json = File.read('package.json')
        json = JSON.parse(package_json)
        json['version']
      else
        default_value
      end
    end

    def package_json_file (dir = '.')
      name = File.join(dir, 'package.json')
      if File.exist? name
        package_json = File.read(name)
        JSON.parse(package_json)
      else
        {}
      end
    end

    def save_package_json_file (json, dir = '.')
      name = File.join(dir, 'package.json')
      if File.exist? name
        File.write(name, JSON.pretty_generate(json))
      end
    end

    def republish_push
      name = '.republish_push.yml'
      if File.exist? name
        contents = YAML.load_file(name)
      else
        { "push_to" => [] }
      end
    end

    def git_add (path)
      run_cmd "git add #{path}"
    end

    def git_show_branches
      run_cmd "git branch"
    end

    def git_checkout ( branch )
      run_cmd "git checkout #{branch}"
    end

    def git_fetch
      run_cmd "git fetch origin -p && git fetch origin --tags"
    end

    def git_remote_merge ( branch )
      run_cmd "git merge origin/#{branch} -m 'merged by release'"
    end

    def is_remote_branch (branch)
      `git branch -r|grep origin|grep -v 'HEAD'|grep #{branch}`.strip != ""
    end

    def git_fetch_and_merge (branch)
      git_fetch
      if is_remote_branch(branch)
        git_remote_merge branch
      end
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

    def git_checkout_track (branch)
      run_cmd "git checkout --track origin/#{branch}"
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
