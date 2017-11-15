require_relative './base'

module Release

  class Start < Release::Base
    def valid?
      argv.size == 4 or argv.size == 6
    end

    def help
      "release start (major|minor|patch) from version [using master]"
    end

    def execute
      case argv.size
      when 4
        subcommand, level, verb, version = *argv
        starting_branch = nil
      when 6
        subcommand, level, verb, version, verb2, starting_branch = *argv
        validate_branch_is_master(starting_branch)
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

      starting_branch = release_tag_from_version(version) unless starting_branch

      validate_version_does_not_exist new_version
      validate_release_branch_does_not_exist(release_branch_from_version(new_version))

      git_local_branch_create release_branch_from_version(new_version), starting_branch
      git_push_upstream(release_branch_from_version(new_version))

      update_package_json new_version, "#{new_version} started"
      git_push(release_branch_from_version(new_version))
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
