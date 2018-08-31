require_relative './base'

module Feature

  class Republish < Feature::Base
    def valid?
      argv.size == 1
    end

    def help
      "feature republish"
    end

    def execute
      parts = parse_branch(current_branch)

      standard_branch = parts[:standard]
      feature_branch  = current_branch
      remote_branch   = remote_branch(feature_branch)

      error "USAGE: feature republish" unless standard_branch
      error "invalid feature branch: #{feature_branch}" if standard_branches.include? feature_branch

      git_checkout standard_branch
      git_fetch
      git_pull standard_branch
      git_checkout feature_branch
      git_rebase standard_branch

      if remote_branch != ""
        git_remote_branch_delete feature_branch
      end

      git_push feature_branch

      version = package_json_version('0.0.0-0')
      tags = `git tag -l`.strip.split("\n").select {|x| x.start_with? version}
      tags = tags.map {|x| x =~ /^\d+.\d+.\d+[-]\d+$/ ? x.split('-').last : '0'}
      tags = tags.map {|x| x.to_i }
      tags << 0
      new_number = tags.uniq.max + 1
      new_tag = "#{version}-#{new_number}"

      git_local_tag new_tag
      git_push_tags
      
      data = republish_push
      data['push_to'].each do |repo|
        puts "updating #{repo}"
        repo_dir = File.join(Dir.pwd, '..', repo)
        json = package_json_file repo_dir
        update_tag data['name'], json['dependencies'], new_tag
        update_tag data['name'], json['devDependencies'], new_tag
        save_package_json_file json, repo_dir
      end

    end

  private

    def update_tag name, dependencies, new_tag
      dependencies.keys.each do |key|
        if key == name
          value = dependencies[key]
          parts = value.split('#')
          dependencies[key] = [parts.first,'#',new_tag].join
        end
      end
    end

  end

end
