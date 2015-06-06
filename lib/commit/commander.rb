module Commit

  class Commander
    attr_reader :argv

    def initialize (argv)
      @argv = argv
    end

    def valid?
      argv.size > 0
    end

    def help
      puts
      puts "USAGE: commit [word....]"
      puts
      exit
    end

    def execute
      comment = argv.reject { |x| x == '-m' }.join(' ')

      command = "git commit -m \"#{comment}\""
      exec command
    end

  end

end
