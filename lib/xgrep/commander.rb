require 'ostruct'
require 'optparse'

require_relative './custom_env'
require_relative './node_env'
require_relative './rails_env'
require_relative './simple_env'

module Xgrep

  class Commander

    attr_accessor :options

    def initialize (argv)
      @options = OpenStruct.new
      options.debug = false
      options.git_grep = %w{-E}
      options.pathspec = []
      options.environment = default_environment

      @option_parser = OptionParser.new do |op|
        op.banner = "Usage: xgrep options term(s)"

        op.on('-d','--[no-]debug') do |argument|
          options.debug = argument
        end

        op.on('-f','--file') do |argument|
          options.git_grep << "-L"
        end

        op.on('-i','--invert') do |argument|
          options.git_grep << '-v'
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
      options.terms.size > 0
    end

    def help
      puts @option_parser
      exit
    end

    def execute
      env = options.environment
      env.update_pathspec(options.pathspec)

      ands = []
      ors  = []
      nots = []
      current_op = ands

      options.terms.each do |x|
        case x
        when 'and'               then current_op = ands
        when 'or'                then current_op = ors
        when 'not'               then current_op = nots
        when /^-+(and|or|not)$/i then current_op << $1
        else                          current_op << x
        end
      end

      ands = ands.map { |x| "-e \"#{x}\"" }
      ors  = ors.map { |x| "-e \"#{x}\"" }
      nots = nots.map { |x| "-e \"#{x}\"" }

      ands << "\\( #{ors.join(' --or ')} \\)"        unless ors.empty?
      ands << "--not \\( #{nots.join(' --or ')} \\)" unless nots.empty?

      command = "git grep #{options.git_grep.join(' ')} #{ands.join(' --and ')} -- #{env.pathspec.sort.join(' ')}"
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
      if File.exist?('./.xgrep')
        Xgrep::CustomEnv.new
      else
        Xgrep::SimpleEnv.new
      end
    end
  end

end
