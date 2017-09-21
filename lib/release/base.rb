require_relative '../shared/branchability'
require_relative '../shared/runnable'

module Release

  class Base

    include Shared::Branchability
    include Shared::Runnable

    attr_reader :argv

    def initialize (argv)
      @argv = argv
    end

    def help
      "TBD"
    end

    def usage
      puts
      puts "USAGE: #{help}"
      puts
      exit
    end

    private

      def validate_version_format (version)
        error "Invalid version number format. Try using MAJOR.MINOR.PATCH."  unless version =~ /\d+\.\d+\.\d+/
      end

      def validate_version_is_new (version)
        error "Version already exists: #{git_local_list_tags.join(' ')}" if git_local_list_tags.include? "v#{version}"
      end

      def validate_version_exists (version)
        error "Version does not exist: #{git_local_list_tags.join(' ')}" unless git_local_list_tags.include? "v#{version}"
      end

      def validate_current_branch_is_release
        error "Invalid release branch: #{current_branch}" unless current_branch =~ /\d+\.\d+\.\d+/
      end

      def validate_current_branch_master
        error "Invalid starting branch: #{current_branch}.  Try switching to #{standard_branches.join(' ')}."  unless standard_branches.include? current_branch
      end

      def validate_release_branch_does_not_exist (branch)
        error "Version branch already exists: #{branch}" if remote_branch(branch) != ""
      end
  end

end
