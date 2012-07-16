module Scripted
  module Formatters
    class Blank

      attr_reader :out

      def initialize(out)
        @out = out || STDERR
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

      private

      def red(text)
        "\e[31m#{text}\e[0m"
      end

      def gray(text)
        "\e[30m#{text}\e[0m"
      end

    end
  end
end
