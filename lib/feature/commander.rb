module Feature

  class Commander
    attr_reader :subcommand

    def initialize (argv)
      key = (argv[0] ? argv[0].to_sym : :branch)
      @subcommand = Commander.create(key,argv)
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

    def self.commands
      [
        :branch,
        :commit,
        :help,
        :end,
        :rebase,
        :merge,
        :start,
        :tab,
        :trash
      ].sort
    end

    def self.create key, argv
      key = "help" unless Commander.commands.include? key
      require_relative "./#{key}"
      klass = Module.const_get "Feature::#{key.capitalize}"
      klass.new(argv)
    end

    def self.create_all argv
      commands.map { |x| create(x,argv) }
    end
  end

end
