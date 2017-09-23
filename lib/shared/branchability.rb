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

    def version_pattern
      /\d+\.\d+\.\d+/
    end

    def release_branch_pattern
      /rc\d+\.\d+\.\d+/
    end

    def release_branch_from_version (version)
      "rc#{version}"
    end

    def release_tag_prefix
      'v'
    end
    
    def release_tag_from_version (version)
      "v#{version}"
    end

    def version_from_release_branch (branch)
      branch.sub(/^rc/, '')
    end

    def parse_branch (branch)
      parts = branch.split('-')
      error "invalid branch: user-standard-feature" unless parts.size > 2

      user     = parts.shift
      standard = parts.shift
      error "invalid user: #{user}" unless [ENV['FEATURE_USER'],ENV['USER']].include? user
      error "invalid branch: #{standard}" unless standard_branches.include? standard or standard =~ release_branch_pattern
      feature  =  parts.join('-')
      { user: user, standard: standard, feature: feature }
    end
  end

end
