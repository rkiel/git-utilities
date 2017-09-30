require_relative './base'

module Release

  class List < Release::Base
    def valid?
      argv.size == 1
    end

    def help
      "release list"
    end

    def execute
      validate_current_branch_master
      git_pull current_branch
      
      puts
      puts show_existing_tags
      puts
      puts show_existing_branches
      puts
    end
  end

end
