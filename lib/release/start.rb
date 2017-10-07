require_relative './base'

module Release

  class Start < Release::Base
    def valid?
      argv.size == 3 or argv.size == 4
    end

    def help
      "release start (major|minor|patch) [from] version"
    end

    def execute
      case argv.size
      when 3
        subcommand, level, version = *argv
      when 4
        subcommand, level, verb, version = *argv
      end

      validate_version_format version

      validate_current_branch_master
      git_fetch_and_merge current_branch

      validate_version_exists version

      numbers = version.split('.').map { |x| x.to_i }
      case level
      when 'major'
        new_version = "#{numbers[0]+1}.0.0"
      when 'minor'
        new_version = "#{numbers[0]}.#{numbers[1]+1}.0"
      when 'patch'
        new_version = "#{numbers[0]}.#{numbers[1]}.#{numbers[2]+1}"
      else
        error "unknow release level: #{level}"
      end

      validate_version_does_not_exist new_version
      validate_release_branch_does_not_exist(release_branch_from_version(new_version))

      git_local_branch_create release_branch_from_version(new_version), release_tag_from_version(version)
      git_push_upstream(release_branch_from_version(new_version))
    end

    private

    def subcommand_name
      error "override"
    end

    def increment_version (version)
      error "override"
    end

  end

end
