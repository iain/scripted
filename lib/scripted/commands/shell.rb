require 'childprocess'

module Scripted
  module Commands
    class Shell

      attr_reader :command

      def initialize(command)
        @command = command
      end

      def execute!(log = $stdout)
        process = ChildProcess.build(command)

        process.io.stdout = log
        process.io.stderr = log
        process.start

        process.wait
        process.exit_code == 0
      end

    end
  end
end
