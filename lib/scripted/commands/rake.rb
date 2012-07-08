module Scripted
  module Commands
    class Rake

      attr_reader :command

      def initialize(command)
        @command = command
      end

      def execute!(log = STDOUT)
        task = Rake::Task[command]
      rescue NameError
        # not running from within Rake, so falling back shelling out
        Shell.new("rake #{command} --trace").execute!(log)
      else
        task.invoke
      end

    end
  end
end
