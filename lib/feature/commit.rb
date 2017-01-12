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

      force = argv.include? '-f'
      comment = argv.reject { |x| ['-m','-f'].include? x }
      comment.shift if comment[0] == 'commit'
      comment = comment.join(' ')
      comment = "#{parts[:feature]}: #{comment}"

      git_commit comment, force
    end
  end

end
