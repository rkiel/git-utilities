require_relative './base'
require_relative './commander'
require_relative './loader'

module Feature

  class Tab < Feature::Base

    COMMANDS = Feature::Commander::COMMANDS
    DEFAULT  = Feature::Commander::DEFAULT

    def valid?
      [1,2].include? argv.size
    end

    def help
      "feature tab [pattern]"
    end

    def execute
      if argv.size == 1
        pattern = '.+'
      elsif argv.size == 2
        pattern = "^#{argv[1]}"
      end

      loader = Feature::Loader.new(COMMANDS,DEFAULT)
      puts loader.search(pattern).join("\n")
    end
  end

end
