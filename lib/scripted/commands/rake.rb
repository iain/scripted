module Scripted
  module Commands
    class Rake

      def initialize(task)
        @task = task
      end

      def execute!
        begin
          task = Rake::Task[@task]
        rescue NameError
          # not running from within Rake, so falling back shelling out
          system "rake #{@task}"
          return $?.to_i == 0
        else
          task.invoke
          return true
        end
      rescue Exception => error
        puts "#{error.class}: #{error}"
        puts error.backtrace
        return false
      end

    end
  end
end
