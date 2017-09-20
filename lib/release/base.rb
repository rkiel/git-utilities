require_relative '../shared/branchability'
require_relative '../shared/runnable'

module Release

  class Base

    include Shared::Branchability
    include Shared::Runnable

    attr_reader :argv

    def initialize (argv)
      @argv = argv
    end

    def help
      "TBD"
    end

    def usage
      puts
      puts "USAGE: #{help}"
      puts
      exit
    end
  end

end
