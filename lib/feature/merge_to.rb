require_relative './base'

module Feature

  class MergeTo < Feature::Base
    def valid?
      [1,2].include? argv.size
    end

    def help
      "feature merge [branch]"
    end

    def execute
      parts = parse_branch(current_branch)

      if argv.size == 2
        merge_to_branch = argv[1]
      elsif argv.size == 1
        merge_to_branch = parts[:standard]
      end

      feature_branch  = current_branch

      error "invalid branch: #{merge_to_branch}" unless standard_branches.include? merge_to_branch

      git_checkout merge_to_branch
      git_pull     merge_to_branch
      git_merge    feature_branch
      git_push     merge_to_branch
      git_checkout feature_branch
    end
  end

end
