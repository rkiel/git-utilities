require_relative './base'

module Release

  class Minor < Release::Base
    def valid?
      argv.size > 1
    end

    def help
      "release minor version"
    end

    def execute
      subcommand, version, *extras = *argv

      error "invalid version: #{version}"  unless version =~ /\d+\.\d+\.\d+/
      error "unknown version: #{git_local_list_tags.join(' ')}" unless git_local_list_tags.include? "v#{version}"
      error "invalid base branch: #{current_branch}"  unless standard_branches.include? current_branch

      minor_branch = minor(version)

      git_pull current_branch

      git_local_branch_create minor_branch, "v#{version}"

      git_push minor_branch
    end

    private

    def minor (version)
      numbers = version.split('.').map { |x| x.to_i }
      "#{numbers[0]}.#{numbers[1]+1}.0"
    end

  end

end
