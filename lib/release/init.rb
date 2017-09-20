require_relative './base'

module Release

  class Init < Release::Base
    def valid?
      argv.size > 1
    end

    def help
      "release init version"
    end

    def execute
      subcommand, version, *extras = *argv

      error "invalid version: #{version}"  unless version =~ /\d+\.\d+\.\d+/
      error "existing version: #{git_local_list_tags.join(' ')}" if git_local_list_tags.include? "v#{version}"
      error "invalid base branch: #{current_branch}"  unless standard_branches.include? current_branch

      git_pull current_branch

#      git_local_tag version

      git_push_tags

    end
  end

end
