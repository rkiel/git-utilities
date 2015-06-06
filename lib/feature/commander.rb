require_relative './start'
require_relative './end'
require_relative './rebase'
require_relative './merge_to'
require_relative './branch'

module Feature

  class Commander
    attr_reader :argv

    def initialize (argv)
      @argv = argv
    end

    def valid?
      true
    end

    def help
      exit
    end

    def execute
      command = case argv[0]
                when "start"  then Feature::Start.new(argv)
                when "end"    then Feature::End.new(argv)
                when "rebase" then Feature::Rebase.new(argv)
                when "merge"  then Feature::MergeTo.new(argv)
                else               Feature::Branch.new(argv)
                end
      command.execute
    end

  end

end
