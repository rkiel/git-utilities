module Xgrep
  class SimpleEnv
    attr_accessor :pathspec

    def initialize
      @pathspec = { }
    end

    def update_pathspec ( pathspec )
    end
  end
end
