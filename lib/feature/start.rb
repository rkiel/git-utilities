require_relative './base'

module Feature

  class Start < Feature::Base
    def valid?
      argv.size == 2
    end

    def help
      puts
      puts "USAGE: feature start feature_name"
      puts
      exit
    end

    def execute
      feature = argv[1]
      feature_branch = "#{ENV['USER']}-#{current_branch}-#{feature}"

      error "invalid base branch: #{current_branch}" unless standard_branches.include? current_branch
      error "invalid feature branch: #{featureh}"    if     standard_branches.include? feature

      git_pull current_branch

      git_local_branch_create feature_branch

      git_push feature_branch
    end
  end

end
