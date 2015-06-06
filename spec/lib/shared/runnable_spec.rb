require 'minitest/autorun'

require_relative '../../../lib/shared/runnable'

describe Shared::Runnable do
  include Shared::Runnable

  describe "git commands" do

    def run_cmd (cmd)
      cmd
    end

    before do
      @branch = "branch-name"
    end

    it "should show branches" do
      git_show_branches.must_equal "git branch"
    end
    it "should checkout" do
      git_checkout(@branch).must_equal "git checkout branch-name"
    end
    it "should remote branch delete" do
      git_remote_branch_delete(@branch).must_equal "git push origin :branch-name"
    end
    it "should local branch delete" do
      git_local_branch_delete(@branch).must_equal "git branch -d branch-name"
    end
    it "should local branch trash" do
      git_local_branch_trash(@branch).must_equal "git branch -D branch-name"
    end
    it "should prune remote branches" do
      git_prune.must_equal "git remote prune origin"
    end
    it "should pull" do
      git_pull(@branch).must_equal "git pull origin branch-name"
    end
    it "should merge" do
      git_merge(@branch).must_equal "git merge branch-name"
    end
    it "should push" do
      git_push(@branch).must_equal "git push origin branch-name"
    end
    it "should rebase" do
      git_rebase(@branch).must_equal "git rebase branch-name"
    end
    it "should create local branch" do
      git_local_branch_create(@branch).must_equal "git checkout -b branch-name"
    end
    it "should commit" do
      git_commit('test message').must_equal 'git commit -m "test message"'
    end
  end
end
