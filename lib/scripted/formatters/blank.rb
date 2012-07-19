module Scripted
  module Formatters
    class Blank

      attr_reader :out, :configuration

      def initialize(out, configuration)
        if out.nil?
          @out = STDERR
        elsif out.is_a?(String)
          @out = File.open(out, 'w:utf-8')
        else
          @out = out
        end
        @configuration = configuration
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

      def red(text);      color(31, text);  end
      def green(text);    color(32, text);  end
      def yellow(text);   color(33, text);  end
      def blue(text);     color(34, text);  end
      def magenta(text);  color(35, text);  end
      def cyan(text);     color(36, text);  end
      def white(text);    color(37, text);  end

      def color(code, text)
        if configuration.color?
          "\e[#{code}m#{text}\e[0m"
        else
          text
        end
      end

      def puts(*args)
        out.puts(*args)
      end

    end
  end
end
