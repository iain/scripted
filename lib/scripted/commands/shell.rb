module Scripted
  module Commands
    class Shell

      attr_reader :command

      def initialize(command)
        @command = command
      end

      def execute!(log = STDOUT)
        process = ChildProcess.build(command)

        process.io.stdout = log
        process.io.stderr = log
        process.start

        process.wait
        if process.exit_code != 0
          fail CommandFailed, command
        end
      end

    end
  end
end
