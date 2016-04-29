module Xgrep
  class SimpleEnv
    attr_accessor :pathspec

    def initialize
      @pathspec = { }
    end

    def update_pathspec ( pathspec )
      files = %w{}
      dirs  = %w{.}
      specs = %w{}

      if pathspec.empty?
        @pathspec = files + dirs + specs
      else
        @pathspec = pathspec
      end
    end
  end
end
