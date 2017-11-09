require 'ostruct'
require 'optparse'
require 'json'

module Setup

  class Commander

    attr_accessor :options

    def initialize (argv)
      @options = OpenStruct.new

      @option_parser = OptionParser.new do |op|
        op.banner = "Usage: setup options"

        op.on('-u','--user USER') do |argument|
          options.user = argument
        end

        op.on_tail('-h','--help') do |argument|
          puts op
          exit
        end
      end

      @option_parser.parse!(argv)
      options.terms = argv # must be after parse!
    end

    def valid?
      options.user
    end

    def help
      puts @option_parser
      exit
    end

    def execute
      action = options.action


      File.open("#{ENV['HOME']}/.bash_profile", "a") do |f|
        f.puts
        f.puts '#############################################################'
        f.puts "# added by ~/GitHub/rkiel/git-utilities/install/bin/setup"
        f.puts '#############################################################'
        f.puts 'export GIT_UTILITIES_BIN="~/GitHub/rkiel/git-utilities/bin"'
        f.puts 'export PATH=${GIT_UTILITIES_BIN}:$PATH'
        f.puts 'source ~/GitHub/rkiel/git-utilities/dotfiles/git-completion.bash'
        f.puts 'source ~/GitHub/rkiel/git-utilities/dotfiles/git-prompt.sh'
        f.puts "export FEATURE_USER=#{options.user}" if options.user
        f.puts '#############################################################'
        f.puts
      end

      File.open("#{ENV['HOME']}/.bashrc", "a") do |f|
        f.puts
        f.puts '#############################################################'
        f.puts "# added by ~/GitHub/rkiel/git-utilities/install/bin/setup"
        f.puts '#############################################################'
        f.puts 'source ~/GitHub/rkiel/git-utilities/dotfiles/bashrc'
        f.puts '#############################################################'
        f.puts
      end

    end

    private

    def run_cmd ( cmd )
      puts
      puts cmd
      success = system cmd
      unless success
        error "(see above)"
      end
      puts
    end

    def error ( msg )
      puts
      puts "ERROR: #{msg}"
      puts
      exit
    end

  end

end
