require_relative './new_version'

module Release

  class Major < Release::NewVersion

    private

    def subcommand_name
      "major"
    end

    def increment_version (version)
      numbers = version.split('.').map { |x| x.to_i }
      "#{numbers[0]+1}.0.0"
    end

  end

end
