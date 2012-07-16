module Scripted
  module Commands
    class Ruby

      def initialize(code)
        @code = code
      end

      def execute!(log = STDOUT)
        $stdout = log
        $stderr = log
        @code.call
      ensure
        $stdout = STDOUT
        $stderr = STDERR
      end

    end
  end
end
