require_relative './base'

module Feature

  class Start < Feature::Base
    def valid?
      argv.size > 1
    end

    def usage
      puts
      puts "USAGE: feature start feature-words"
      puts
      exit
    end

    def execute
      subcommand, *feature_words = *argv

      feature_name = feature_words.join('-')
      feature_branch = "#{ENV['USER']}-#{current_branch}-#{feature_name}"

      error "invalid base branch: #{current_branch}"  unless standard_branches.include? current_branch
      error "invalid feature branch: #{feature_name}" if     standard_branches.include? feature_name

      git_pull current_branch

      git_local_branch_create feature_branch

      git_push feature_branch
    end
  end

end
