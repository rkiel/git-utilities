require_relative './base'

module Feature

  class Help < Feature::Base
    def valid?
      true
    end

    def help
      "feature help"
    end

    def execute
      puts
      # TODO: fix this
      commander = Feature::Commander.new(argv)
      commander.subcommands.keys.sort.each do |key|
        cmd = commander.subcommands[key]
        puts cmd.help
      end
      puts
    end
  end

end
