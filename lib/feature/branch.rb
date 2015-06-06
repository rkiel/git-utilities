require_relative './base'

module Feature

  class Branch < Feature::Base
    def valid?
      true
    end

    def help
      exit
    end

    def execute
      git_show_branches
    end
  end

end
