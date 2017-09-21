require_relative './new_version'

module Release

  class Minor < Release::NewVersion

    private

    def subcommand_name
      "minor"
    end
    
    def increment_version (version)
      numbers = version.split('.').map { |x| x.to_i }
      "#{numbers[0]}.#{numbers[1]+1}.0"
    end

  end

end
