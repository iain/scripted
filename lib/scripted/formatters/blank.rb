module Scripted
  module Formatters
    class Blank

      attr_reader :raw_out, :configuration

      # Called whn Scripted starts.
      # If you override this, don't forget to call `super`.
      def initialize(out, configuration)
        @raw_out = out || $stderr
        @configuration = configuration
      end

      # Called when the commands to be run have been selected
      # No command has yet been run
      def start(commands, runner)
      end

      # Called after all commands have been run.
      def stop(commands, runner)
      end

      # Called whenever a command has failed.
      def exception(command, exception)
      end

      # Called whenever a command has been run.
      def done(command)
      end

      # Called when an important command has failed.
      def halted(command)
      end

      # Called just before a command starts running
      def execute(command)
      end

      # Called just before scripted exits. Useful for closing streams and
      # closing connections.
      def close
      end

      # Called for each character that went to stdout or stderr.
      # Doesn't include output of other formatters.
      def each_char(output, command)
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
        if color_enabled?
          "\e[#{code}m#{text}\e[0m"
        else
          text
        end
      end

      def out
        @out ||= build_out
      end

      def build_out
        if raw_out.is_a?(String)
          File.open(raw_out, 'w:utf-8')
        else
          raw_out
        end
      end

      def file?
        out.is_a?(File)
      end

      def puts(*args)
        out.puts(*args)
      end

      def print(*args)
        out.print(*args)
      end

      def color_enabled?
        configuration.color? && !out.is_a?(File)
      end

    end
  end
end
