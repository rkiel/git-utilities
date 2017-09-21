require_relative './new_version'

module Release

  class Patch < Release::NewVersion

    private

    def subcommand_name
      "patch"
    end

    def increment_version (version)
      numbers = version.split('.').map { |x| x.to_i }
      "#{numbers[0]}.#{numbers[1]}.#{numbers[2]+1}"
    end

  end

end
