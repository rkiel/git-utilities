require_relative './base'

module Feature

  class Tab < Feature::Base
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

      regexp = Regexp.new(pattern)

      puts Feature::Commander.commands.select { |x| regexp.match(x.to_s) }.join("\n")
    end
  end

end
