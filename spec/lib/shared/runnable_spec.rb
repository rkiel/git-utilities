require 'minitest/autorun'

require_relative '../../../lib/shared/runnable'

describe Shared::Runnable do

  describe "run_cmd" do
    class TestRunCommand
      include Shared::Runnable

      attr_reader :output, :commands, :errors

      attr_accessor :success

      def initialize
        @output   = []
        @commands = []
        @errors   = []
        @success  = true
      end

      def system ( cmd )
        @commands << cmd
        @success
      end

      def puts (message = "")
        @output << message
      end

      def error (message)
        @errors << message
      end

      def current_branch
        "current_branch"
      end
    end

    before do
      @object = TestRunCommand.new
    end

    describe "when success is true" do
      before do
        @object.success = true
      end

      it "should generate output" do
        @object.run_cmd("foo")
        @object.output.must_equal ["", "foo", ""]
      end
      it "should generate commands" do
        @object.run_cmd("foo")
        @object.commands.must_equal ["foo"]
      end
      it "should generate errors" do
        @object.run_cmd("foo")
        @object.errors.must_equal []
      end
    end

    describe "when success is false" do
      before do
        @object.success = false
      end

      it "should generate output" do
        @object.run_cmd("foo")
        @object.output.must_equal ["", "foo", ""]
      end
      it "should generate commands" do
        @object.run_cmd("foo")
        @object.commands.must_equal ["foo", "git checkout current_branch"]
      end
      it "should generate commands with fallback" do
        @object.run_cmd("foo", "fallback_branch")
        @object.commands.must_equal ["foo", "git checkout fallback_branch"]
      end
      it "should generate errors" do
        @object.run_cmd("foo")
        @object.errors.must_equal ["(see above)"]
      end
    end
  end

  describe "error" do
    class TestError
      include Shared::Runnable

      attr_reader :puts, :exit

      def initialize
        @puts = []
        @exit = nil
      end

      def exit
        @exit = "exit"
      end

      def puts (message = "")
        @puts << message
      end
    end

    before do
      @object = TestError.new
    end

    it "should generate messages and exit" do
      @object.error("foo")
      @object.puts.must_equal ["", "ERROR: foo", "", ""]
      @object.exit.must_equal "exit"
    end
  end

  describe "git commands" do
    class TestGitCommands
      include Shared::Runnable
    end

    before do
      @object = TestGitCommands.new
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
