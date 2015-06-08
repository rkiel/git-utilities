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
      Feature::Commander.create_all(argv).each do |cmd|
        puts cmd.help
      end
      puts
    end
  end

end
