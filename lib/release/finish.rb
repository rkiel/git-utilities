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

      validate_current_branch_is_release

      git_pull release_branch

      update_package_json version_from_release_branch(release_branch)

      git_local_tag release_tag_from_version(version_from_release_branch(release_branch))

      git_push release_branch
      git_push_tags

      git_checkout "master"

      #git_merge_message release_branch, "merge #{version_from_release_branch(release_branch)}"

      git_local_branch_delete release_branch

      if remote_branch(release_branch) != ""
        git_remote_branch_delete release_branch
      end

      git_prune
    end
  end

end
