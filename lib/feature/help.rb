require_relative './base'

module Feature

  class Help < Feature::Base
    def valid?
      true
    end

    def usage
      exit
    end

    def execute
    end
  end

end
