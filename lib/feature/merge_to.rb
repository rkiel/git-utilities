require_relative './base'

module Feature

  class MergeTo < Feature::Base
    def valid?
      [1,2].include? argv.size
    end

    def help
      puts
      puts "USAGE: feature merge [branch]"
      puts
      exit
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

      run_cmd "git checkout #{merge_to_branch}"
      run_cmd "git pull origin #{merge_to_branch}"
      run_cmd "git merge #{feature_branch}"
      run_cmd "git push origin #{merge_to_branch}"
      run_cmd "git checkout #{feature_branch}"
    end
  end

end
