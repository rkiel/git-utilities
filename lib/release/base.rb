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

      def show_existing_tags
        git_local_list_tags(release_tag_prefix).join("\n")
      end

      def show_existing_branches
        git_local_list_branches(release_branch_prefix).join("\n")
      end

      def validate_version_format (version)
        error "Invalid version number format. Try using MAJOR.MINOR.PATCH."  unless version =~ version_pattern
      end

      def validate_version_is_new (version)
        error "Version already exists: \n#{show_existing_tags}" if git_local_list_tags(release_tag_prefix).include? release_tag_from_version(version)
      end

      def validate_version_exists (version)
        error "Version does not exist: \n#{show_existing_tags}" unless git_local_list_tags(release_tag_prefix).include? release_tag_from_version(version)
      end

      def validate_version_does_not_exist (version)
        error "Version already exists: \n#{show_existing_tags}" if git_local_list_tags(release_tag_prefix).include? release_tag_from_version(version)
      end

      def validate_current_branch_is_release
        error "Invalid release branch: #{current_branch}" unless current_branch =~ release_branch_pattern
      end

      # TODO: Remove
      # def validate_current_branch_master
      #   error "Invalid starting branch: #{current_branch}.  Try switching to #{standard_branches.join(' ')}."  unless standard_branches.include? current_branch
      # end

      def validate_current_branch_default
        error "Invalid starting branch: #{current_branch}. Try switching to #{standard_branches.join(' ')}." unless standard_branches.include?(current_branch)
      end

      def validate_release_branch_does_not_exist (branch)
        error "Version branch already exists: #{branch}" if remote_branch(branch) != ""
      end

      # TODO: Remove
      # def validate_branch_is_master (branch)
      #   error "Branch must be master: #{branch}" if branch != "master"
      # end
      
      def validate_branch_is_default (branch)
        error "Branch must be #{default_branch}: #{branch}" if branch != default_branch
      end

  end

end
