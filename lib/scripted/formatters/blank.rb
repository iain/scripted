module Scripted
  module Formatters
    class Blank

      attr_reader :out

      def initialize(out)
        @out = out
      end

      def start(commands)
      end

      def stop
      end

      def exception(command, exception)
      end

      def done(command)
      end

      def halted
      end

      def execute(command)
      end

      def close
      end

      def <<(output)
      end

    end
  end
end
