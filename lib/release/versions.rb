require_relative './base'

module Release

  class Versions < Release::Base
    def valid?
      true
    end

    def help
      "release versions"
    end

    def execute
      puts
      puts show_existing_tags
      puts
    end
  end

end
