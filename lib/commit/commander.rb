require_relative '../shared/branchability'
require_relative '../shared/runnable'

module Commit

  class Commander

    include Shared::Branchability
    include Shared::Runnable

    attr_reader :argv

    def initialize (argv)
      @argv = argv
    end

    def valid?
      argv.size > 0
    end

    def help
      puts
      puts "USAGE: commit [word....]"
      puts
      exit
    end

    def execute
      parts = parse_branch(current_branch)

      comment = argv.reject { |x| x == '-m' }.join(' ')
      comment = "#{parts[:feature]}: #{comment}"

      git_commit comment
    end

  end

end
