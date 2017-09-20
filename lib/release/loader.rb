module Release

  class Loader
    attr_reader :commands, :default

    def initialize commands, default
      @commands = commands
      @default  = default
    end

    def create key, argv
      key = default unless commands.include? key
      require_relative "./#{key}"
      klass = Module.const_get "Release::#{key.to_s.capitalize}"
      klass.new(argv)
    end

    def create_all argv
      commands.map { |x| create(x,argv) }
    end

    def search pattern
      regexp = Regexp.new(pattern)
      commands.select { |x| regexp.match(x.to_s) }
    end
  end

end
