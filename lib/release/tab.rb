require_relative './base'
require_relative './commander'
require_relative './loader'

module Release

  class Tab < Release::Base

    COMMANDS = Release::Commander::COMMANDS
    DEFAULT  = Release::Commander::DEFAULT

    def valid?
      [1,2].include? argv.size
    end

    def help
      "release tab [pattern]"
    end

    def execute
      if argv.size == 1
        pattern = '.+'
      elsif argv.size == 2
        pattern = "^#{argv[1]}"
      end

      loader = Release::Loader.new(COMMANDS,DEFAULT)
      puts loader.search(pattern).join("\n")
    end
  end

end
