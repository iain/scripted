module Scripted
  module Commands
    class Ruby

      def initialize(code)
        @code = code
      end

      def execute!(log = STDOUT)
        old_stdout = $stdout
        old_stderr = $stderr
        $stdout = log
        $stderr = log
        @code.call
      ensure
        $stdout = old_stdout
        $stderr = old_stderr
      end

    end
  end
end
