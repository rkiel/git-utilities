require_relative './start'
require_relative './end'
require_relative './trash'
require_relative './rebase'
require_relative './merge_to'
require_relative './tab'
require_relative './branch'
require_relative './commit'
require_relative './help'

module Feature

  class Commander
    attr_reader :subcommands, :subcommand

    def initialize (argv)
      @subcommands = {
        branch: Feature::Branch.new(argv),
        commit: Feature::Commit.new(argv),
        help:   Feature::Help.new(argv),
        end:    Feature::End.new(argv),
        rebase: Feature::Rebase.new(argv),
        merge:  Feature::MergeTo.new(argv),
        start:  Feature::Start.new(argv),
        tab:    Feature::Tab.new(argv),
        trash:  Feature::Trash.new(argv)
      }

      key = (argv[0] ? argv[0].to_sym : :branch)

      @subcommand = (subcommands[key] ? subcommands[key] : subcommands[:help])
    end

    def valid?
      subcommand.valid?
    end

    def usage
      subcommand.usage
    end

    def execute
      subcommand.execute
    end

  end

end
