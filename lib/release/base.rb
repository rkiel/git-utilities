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
        error "invalid version number format: #{version}"  unless version =~ /\d+\.\d+\.\d+/
      end

      def validate_version_is_new (version)
        error "version already exists: #{git_local_list_tags.join(' ')}" if git_local_list_tags.include? "v#{version}"
      end

      def validate_current_branch_master
        error "invalid starting branch: #{current_branch}"  unless standard_branches.include? current_branch
      end
  end

end
