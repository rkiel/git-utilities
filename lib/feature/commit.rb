require_relative './base'

module Feature

  class Commit < Feature::Base
    def valid?
      argv.size > 1
    end

    def help
      "feature commit [word....]"
    end

    def execute
      parts = parse_branch(current_branch)

      comment = argv.reject { |x| x == '-m' }.join(' ')
      comment = "#{parts[:feature]}: #{comment}"

      git_commit comment
    end
  end

end
