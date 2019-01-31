require_relative './base'

module Feature

  class Start < Feature::Base
    def valid?
      argv.size > 1
    end

    def help
      "feature start feature-words"
    end

    def execute
      subcommand, *feature_words = *argv

      feature_name = feature_words.join('-')
      feature_branch = "#{ENV['FEATURE_USER']||ENV['USER']}-#{current_branch}-#{feature_name}"

      error "invalid base branch: #{current_branch}"  unless standard_branches.include? current_branch or current_branch =~ /\d+\.\d+\.\d+/
      error "invalid feature branch: #{feature_name}" if     standard_branches.include? feature_name

      git_fetch
      git_merge ['origin', current_branch].join('/')
      git_branch feature_branch
      git_checkout feature_branch
      git_push feature_branch
      
    end
  end

end
