module Xgrep
  class NodeEnv
    attr_accessor :pathspec

    def initialize
      @pathspec = { }
    end

    def update_pathspec ( pathspec )
    end
  end
end
