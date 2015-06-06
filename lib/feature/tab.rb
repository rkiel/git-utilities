require_relative './base'

module Feature

  class Tab < Feature::Base
    def valid?
      argv.size > 0
    end

    def help
      puts
      puts "USAGE: feature tab [pattern]"
      puts
      exit
    end

    def execute
      if argv.size == 1
        pattern = '.+'
      else
        pattern = "^#{argv[1]}"
      end

      regexp = Regexp.new(pattern)
      cmds = Feature::Commander.tab_completion
      cmds = cmds.select { |x| regexp.match(x) }

      puts cmds.join("\n")
    end
  end

end
