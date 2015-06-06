require_relative './base'

module Feature

  class Start < Feature::Base
    def execute
      error "USAGE: feature start feature_name" unless argv.size == 2

      feature = argv[1]
      feature_branch = "#{ENV['USER']}-#{current_branch}-#{feature}"

      error "invalid base branch: #{current_branch}" unless standard_branches.include? current_branch
      error "invalid feature branch: #{featureh}"    if     standard_branches.include? feature

      run_cmd "git pull origin #{current_branch}"

      run_cmd "git checkout -b #{feature_branch}"

      run_cmd "git push origin #{feature_branch}"
    end
  end

end
