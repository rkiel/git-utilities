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
      run_cmd "git branch"
    end
  end

end
