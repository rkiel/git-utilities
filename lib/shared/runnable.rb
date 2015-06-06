module Shared

  module Runnable
    def run_cmd ( cmd, fallback_branch = current_branch )
      puts
      puts cmd
      success = system cmd
      unless success
        system "git checkout #{fallback_branch}"
        error "(see above)"
      end
      puts
    end

    def error ( msg )
      puts
      puts "ERROR: #{msg}"
      puts
      exit
    end
  end

end
