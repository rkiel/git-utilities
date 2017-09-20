require_relative './base'

module Release

  class Finish < Release::Base
    def valid?
      argv.size == 1
    end

    def help
      "release finish"
    end

    def execute
      release_branch  = current_branch

      error "invalid release branch: #{release_branch}" unless release_branch =~ /\d+\.\d+\.\d+/

      git_pull release_branch

      git_local_tag release_branch

      git_push release_branch

      git_push_tags

      git_checkout "master"

      git_local_branch_delete release_branch

      if remote_branch(release_branch) != ""
        git_remote_branch_delete release_branch
      end

      git_prune
    end
  end

end
