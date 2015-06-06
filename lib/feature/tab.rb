require_relative './base'

module Feature

  class Tab < Feature::Base
    def valid?
      [1,2].include? argv.size
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
      elsif argv.size == 2
        pattern = "^#{argv[1]}"
      end

      regexp = Regexp.new(pattern)
      cmds = Feature::Commander.tab_completion
      cmds = cmds.select { |x| regexp.match(x) }

      puts cmds.join("\n")
    end
  end

end
