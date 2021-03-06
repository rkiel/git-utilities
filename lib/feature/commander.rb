require_relative './loader'

module Feature

  class Commander

    COMMANDS = [
      :branch,
      :commit,
      :help,
      :end,
      :rebase,
      :republish,
      :merge,
      :start,
      :tab,
      :trash
    ].sort

    DEFAULT = :help

    attr_reader :subcommand

    def initialize (argv)
      key = (argv[0] ? argv[0].to_sym : :branch)
      @subcommand = Feature::Loader.new(COMMANDS,DEFAULT).create(key,argv)
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
