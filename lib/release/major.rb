require_relative './base'

module Release

  class Major < Release::Base
    def valid?
      argv.size > 1
    end

    def help
      "release major version"
    end

    def execute
      subcommand, version, *extras = *argv

      error "invalid version: #{version}"  unless version =~ /\d+\.\d+\.\d+/
      error "unknown version: #{git_local_list_tags.join(' ')}" unless git_local_list_tags.include? "v#{version}"
      error "invalid base branch: #{current_branch}"  unless standard_branches.include? current_branch

      major_branch = major(version)

      git_pull current_branch

      git_local_branch_create major_branch, "v#{version}"

      git_push major_branch
    end

    private

    def major (version)
      numbers = version.split('.').map { |x| x.to_i }
      "#{numbers[0]+1}.0.0"
    end

  end

end
