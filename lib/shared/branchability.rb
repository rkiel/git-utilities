module Shared

  module Branchability
    def current_branch
      @current_branch ||= `git branch|grep '\*'|sed 's/\*\s*//'`.strip
    end

    def remote_branch (branch)
      @remote_branch  ||= `git branch -r|grep origin|grep -v 'HEAD'|grep #{branch}`.strip
    end

    def standard_branches
      ['master']
    end

    def parse_branch (branch)
      parts = branch.split('-')
      error "invalid branch: user-standard-feature" unless parts.size > 2

      user     = parts.shift
      standard = parts.shift
      error "invalid user: #{user}" unless [ENV['FEATURE_USER'],ENV['USER']].include? user
      error "invalid branch: #{standard}" unless standard_branches.include? standard or standard =~ /\d+\.\d+\.\d+/
      feature  =  parts.join('-')
      { user: user, standard: standard, feature: feature }
    end
  end

end
