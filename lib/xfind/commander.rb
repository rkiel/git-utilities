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
        {exclude: true, pattern: '.git'},
        {exclude: true, pattern: 'node_modules'}
      ]

      @option_parser = OptionParser.new do |op|
        op.banner = "Usage: xfind options term(s)"

        op.on('-d','--[no-]debug') do |argument|
          options.debug = argument
        end

        op.on('-n NAME', 'include NAME') do |argument|
          options.names << {exclude: false, pattern: argument}
        end

        op.on('-N NAME','exclude NAME') do |argument|
          options.names << {exclude: true, pattern: argument}
        end

        op.on('-p PATH','include PATH') do |argument|
          options.paths << {exclude: false, pattern: argument}
        end

        op.on('-P PATH','exclude PATH') do |argument|
          options.paths << {exclude: true, pattern: argument}
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
      include_paths = options.paths.reject {|x| x[:exclude] }.map {|x| "-path '*/#{x[:pattern]}/*'"}
      if include_paths.size > 1
        include_paths = include_paths.join(' -o ')
        include_paths = ['\(', include_paths, '\)']
      end
      include_paths = include_paths.join(' ')

      exclude_paths = options.paths.select {|x| x[:exclude] }.map {|x| "! -path '*/#{x[:pattern]}/*'"}
      if exclude_paths.size > 1
        exclude_paths = exclude_paths.join(' -a ')
        exclude_paths = ['\(', exclude_paths, '\)']
      end
      exclude_paths = exclude_paths.join(' ')

      include_names = options.names.reject {|x| x[:exclude] }.map {|x| "-name '*.#{x[:pattern]}'"}
      if include_names.size > 1
        include_names = include_names.join(' -o ')
        include_names = ['\(', include_names, '\)']
      end
      include_names = include_names.join(' ')

      exclude_names = options.names.select {|x| x[:exclude] }.map {|x| "! -name '*.#{x[:pattern]}'"}
      if exclude_names.size > 1
        exclude_names = exclude_names.join(' -a ')
        exclude_names = ['\(', exclude_names, '\)']
      end
      exclude_names = exclude_names.join(' ')


      commands = [
        ["find", ".", "-type f", include_names, exclude_names, include_paths, exclude_paths].join(" "),
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
