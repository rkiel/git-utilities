module Xgrep
  class NodeEnv
    attr_accessor :pathspec

    def initialize
      @pathspec = { }
    end

    def update_pathspec ( pathspec )
      files = %w{app.js Gruntfile.js routes.js server.js package.json}
      dirs  = %w{api app config controllers db lib models routes script views}
      specs = %w{spec test}
      assets = {}
      %w{js css less}.each do |ext|
        assets += Dir.glob("assets/**/*.#{ext}").reject { |x| x =- Regexp.new("\\.min\\.#{ext}$") }
      end

      if pathspec.empty?
        @pathspec = files + dirs + specs
      elsif pathspec.include? :core
        @pathspec = files + dirs
      else
        @pathspec += assets                                          if pathspec.include? :asset
        @pathspec += %w{models      api/models      app/models}      if pathspec.include? :models
        @pathspec += %w{views       api/views       app/views}       if pathspec.include? :views
        @pathspec += %w{controllers api/controllers app/controllers} if pathspec.include? :controllers
        @pathspec += %w{config}                                      if pathspec.include? :config
        @pathspec += %w{db}                                          if pathspec.include? :db
        @pathspec += %w{lib}                                         if pathspec.include? :lib
        @pathspec += %w{spec test}                                   if pathspec.include? :spec
      end
    end
  end
end
