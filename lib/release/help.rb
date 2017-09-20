require_relative './base'
require_relative './commander'
require_relative './loader'

module Release

  class Help < Release::Base

    COMMANDS = Release::Commander::COMMANDS
    DEFAULT  = Release::Commander::DEFAULT

    def valid?
      true
    end

    def help
      "release help"
    end

    def execute
      puts
      loader = Release::Loader.new(COMMANDS,DEFAULT)
      loader.create_all(argv).each do |cmd|
        puts cmd.help
      end
      puts
    end
  end

end
