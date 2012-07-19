require "scripted/formatters/blank"

# The default provides two things:
#
# * Print the regular command output
# * Print exceptions that happen during the output
#
# When running commands in parallel, output would be intertwined. That's why
# this formatter buffers the output if outputting to a file, than the file will
# have the output in the right order at the end.
module Scripted
  module Formatters
    class Default < Blank

      def initialize(*)
        super
        @buffers = Hash.new { |h,k| h[k] = StringIO.new }
      end

      def each_char(output, command)
        if file?
          @buffers[command].print output
        else
          print output
        end
      end

      def exception(command, exception)
        command_puts command, red("  #{exception.class} during the execution of #{command.name.inspect}:")
        exception.to_s.split("\n").each do |line|
          command_puts command, red("    #{line}")
        end
        clean_backtrace(exception.backtrace).each do |line|
          command_puts command, cyan("    # #{line}")
        end
      end

      def close
        if file?
          @buffers.each do |command, output|
            output.rewind
            puts output.read
          end
        end
      end

      def command_puts(command, *args)
        if file?
          @buffers[command].puts *args
        else
          puts *args
        end
      end

      def clean_backtrace(backtrace)
        gem_path = File.expand_path("../../../", __FILE__)
        backtrace.reject { |line| line.start_with?(gem_path) }
      end

    end
  end
end
