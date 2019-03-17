require 'ostruct'
require 'optparse'

module Xfind

  class Commander

    attr_accessor :options

    def initialize (argv)
      @options = OpenStruct.new
      options.debug = false
      options.names = []
      options.paths = [
        '.git',
        'node_modules'
      ]

      @option_parser = OptionParser.new do |op|
        op.banner = "Usage: xfind options term(s)"

        op.on('-d','--[no-]debug') do |argument|
          options.debug = argument
        end

        op.on('-n','--name NAME') do |argument|
          options.names << argument
        end

        op.on('-p','--path PATH') do |argument|
          options.paths << argument
        end

        op.on_tail('-h','--help') do |argument|
          puts op
          exit
        end

      end

      @option_parser.parse!(argv)
      options.terms = argv # must be after parse!
    end

    def valid?
      true #options.terms.size > 0
    end

    def help
      puts @option_parser
      exit
    end

    def execute
      paths = options.paths.map {|x| "! -path '*/#{x}/*'"}.join(' ')

      names = options.names.map {|x| "-name '*.#{x}'"}
      if names.size > 1
        names = names.join(' -o ')
        names = ['\(', names, '\)']
      end
      names = names.join(' ')


      commands = [
        ["find", ".", "-type f", names, paths].join(" "),
        "sort",
      ]
      if options.terms.size > 0
        terms = options.terms.map {|x| "grep --color=auto #{x}"}.join(' | ')
        commands << ["xargs", terms].join(' ')
      end

      command = commands.join('|')
      puts command

      puts
      if options.debug
        puts command
      else
        system command
      end
      puts
    end

    private

    def default_environment
      Xfind::SimpleEnv.new
    end
  end

end
