require_relative './base'

module Release

  class Patch < Release::Base
    def valid?
      argv.size > 1
    end

    def help
      "release patch version"
    end

    def execute
      subcommand, version, *extras = *argv

      error "invalid version: #{version}"  unless version =~ /\d+\.\d+\.\d+/
      error "unknown version: #{git_local_list_tags.join(' ')}" unless git_local_list_tags.include? "v#{version}"
      error "invalid base branch: #{current_branch}"  unless standard_branches.include? current_branch

      patch_branch = patch(version)

      git_pull current_branch

      git_local_branch_create patch_branch, "v#{version}"

      git_push patch_branch
    end

    private

    def patch (version)
      numbers = version.split('.').map { |x| x.to_i }
      "#{numbers[0]}.#{numbers[1]}.#{numbers[2]+1}"
    end

  end

end
