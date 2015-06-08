require_relative './base'
require_relative './commander'
require_relative './loader'

module Feature

  class Help < Feature::Base

    COMMANDS = Feature::Commander::COMMANDS
    DEFAULT  = Feature::Commander::DEFAULT

    def valid?
      true
    end

    def help
      "feature help"
    end

    def execute
      puts
      loader = Feature::Loader.new(COMMANDS,DEFAULT)
      loader.create_all(argv).each do |cmd|
        puts cmd.help
      end
      puts
    end
  end

end
