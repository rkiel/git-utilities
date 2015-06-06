module Feature

  class Base
    attr_reader :argv

    def initialize (argv)
      @argv = argv
    end

    def run_cmd ( cmd, fallback_branch = current_branch )
      puts
      puts cmd
      success = system cmd
      unless success
        system "git checkout #{fallback_branch}"
        error "(see above)"
      end
      puts
    end

    def current_branch
      @current_branch ||= `git branch|grep '\*'|sed 's/\*\s*//'`.strip
    end

    def remote_branch (branch)
      @remote_branch  ||= `git branch -r|grep origin|grep -v 'HEAD'|grep #{branch}`.strip
    end

    def standard_branches
      ['master','develop','integration']
    end

    def parse_branch (branch)
      parts = branch.split('-')
      error "invalid branch: user-standard-feature" unless parts.size > 2

      user     = parts.shift
      standard = parts.shift
      error "invalid user: #{user}" unless ENV['USER'] == user
      error "invalid branch: #{standard}" unless standard_branches.include? standard
      feature  =  parts.join('-')
      { user: user, standard: standard, feature: feature }
    end

    def error ( msg )
      puts
      puts "ERROR: #{msg}"
      puts
      exit
    end

  end

end
