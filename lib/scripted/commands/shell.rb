require 'childprocess'

# These couple of lines should be removed once my Pull Request is merged and released:
# https://github.com/jarib/childprocess/pull/36
require 'childprocess/unix'    if ChildProcess.unix?
require 'childprocess/windows' if ChildProcess.windows?
require 'childprocess/jruby'   if ChildProcess.jruby?

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
