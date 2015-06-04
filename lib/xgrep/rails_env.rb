module Xgrep
  class RailsEnv
    attr_accessor :pathspec

    def initialize
      @pathspec = { }
    end

    def update_pathspec ( pathspec )
      files = %w{Capfile Gemfile Rakefile}
      dirs  = %w{app config db lib}
      specs = %w{spec}

      if pathspec.empty?
        @pathspec = files + dirs + specs
      elsif pathspec.include? :core
        @pathspec = files + dirs
      else
        @pathspec += %w{app/assets}      if pathspec.include? :asset
        @pathspec += %w{app/helpers}     if pathspec.include? :helper
        @pathspec += %w{app/mailers}     if pathspec.include? :mailer
        @pathspec += %w{app/models}      if pathspec.include? :models
        @pathspec += %w{app/views}       if pathspec.include? :views
        @pathspec += %w{app/controllers} if pathspec.include? :controllers
        @pathspec += %w{app/services}    if pathspec.include? :services
        @pathspec += %w{config}          if pathspec.include? :config
        @pathspec += %w{db}              if pathspec.include? :db
        @pathspec += %w{lib}             if pathspec.include? :lib
        @pathspec += %w{spec}            if pathspec.include? :spec
      end
    end
  end
end
