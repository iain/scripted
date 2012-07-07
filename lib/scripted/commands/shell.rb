module Scripted
  module Commands
    class Shell

      attr_reader :command

      def initialize(command)
        @command = command
      end

      def execute!
        system command
        $?.to_i == 0
      rescue Exception => error
        puts error
        puts error.backtrace
        false
      end

    end
  end
end
