require_relative './start'
require_relative './end'
require_relative './trash'
require_relative './rebase'
require_relative './merge_to'
require_relative './tab'
require_relative './branch'
require_relative './commit'

module Feature

  class Commander
    attr_reader :subcommand

    def initialize (argv)
      @subcommand = case argv[0]
        when "start"  then Feature::Start.new(argv)
        when "end"    then Feature::End.new(argv)
        when "trash"  then Feature::Trash.new(argv)
        when "rebase" then Feature::Rebase.new(argv)
        when "merge"  then Feature::MergeTo.new(argv)
        when "tab"    then Feature::Tab.new(argv)
        when "commit" then Feature::Commit.new(argv)
        else               Feature::Branch.new(argv)
      end
    end

    def valid?
      subcommand.valid?
    end

    def help
      subcommand.help
    end

    def execute
      subcommand.execute
    end

    def self.tab_completion
      [:start, :end, :trash, :rebase, :merge, :commit].map(&:to_s).sort
    end

  end

end
