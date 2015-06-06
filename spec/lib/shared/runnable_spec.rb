require 'minitest/autorun'

require_relative '../../../lib/shared/runnable'

describe Shared::Runnable do

  class TestClass
    include Shared::Runnable
  end

  describe "git commands" do

    before do
      @object = TestClass.new
      @branch = "branch-name"
      @run_cmd = lambda do |cmd|
        cmd
      end
    end

    it "should show branches" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_show_branches.must_equal "git branch"
      end
    end
    it "should checkout" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_checkout(@branch).must_equal "git checkout branch-name"
      end
    end
    it "should remote branch delete" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_remote_branch_delete(@branch).must_equal "git push origin :branch-name"
      end
    end
    it "should local branch delete" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_local_branch_delete(@branch).must_equal "git branch -d branch-name"
      end
    end
    it "should local branch trash" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_local_branch_trash(@branch).must_equal "git branch -D branch-name"
      end
    end
    it "should prune remote branches" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_prune.must_equal "git remote prune origin"
      end
    end
    it "should pull" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_pull(@branch).must_equal "git pull origin branch-name"
      end
    end
    it "should merge" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_merge(@branch).must_equal "git merge branch-name"
      end
    end
    it "should push" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_push(@branch).must_equal "git push origin branch-name"
      end
    end
    it "should rebase" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_rebase(@branch).must_equal "git rebase branch-name"
      end
    end
    it "should create local branch" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_local_branch_create(@branch).must_equal "git checkout -b branch-name"
      end
    end
    it "should commit" do
      @object.stub(:run_cmd, @run_cmd) do
        @object.git_commit('test message').must_equal 'git commit -m "test message"'
      end
    end
  end
end
