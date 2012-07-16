# encoding: utf-8
module Scripted
  module Formatters
    class Table < Blank

      def start(commands)
        @commands = commands
      end

      def stop
        report_lines << [ Column["Command"], Column["Runtime"], Column["Status"] ]
        @commands.each do |command|
          report_lines << [ Column[command.name], Column[command.runtime, "s"], Column[status(command)] ]
        end
        widths = report_lines.transpose.map { |line| line.max_by(&:size).size }
        header = report_lines.shift
        puts separator(widths, "┌", "┬", "┐")
        puts report_line(header, widths)
        puts separator(widths, "├", "┼", "┤")
        report_lines.each do |line|
          puts report_line(line, widths)
        end
        puts separator(widths, "└", "┴", "┘")
      end

      private

      def status(command)
        case
        when command.only_when_failed? && command.success?   then "success because something failed"
        when command.only_when_failed? && command.failed?    then "failed because something failed"
        when command.only_when_failed? && !command.executed? then "skipped because nothing failed"
        when command.failed_but_unimportant? then "failed, but ignored"
        when command.success?   then "success"
        when command.halted?    then "failed and halted"
        when command.failed?    then "failed"
        when !command.executed? then "didn't run"
        else "unknown"
        end
      end

      def separator(widths, left, middle, right)
        gray(left) + widths.map { |width| (gray("─") * (width + 2)).force_encoding('utf-8') }.join(gray(middle)) + gray(right)
      end

      def report_line(line, widths)
        gray("│ ") + line.zip(widths).map { |(column, width)| column.aligned(width) }.join(gray(" │ ")) + gray(" │")
      end

      def puts(*args)
        out.puts(*args)
      end

      def report_lines
        @report_lines ||= []
      end

      def gray(text)
        "\e[30m#{text}\e[0m"
      end

      class Column

        attr_reader :value, :suffix

        def self.[](value, suffix = "")
          new(value, suffix)
        end

        def initialize(value, suffix)
          @value, @suffix = value, suffix
        end

        def to_s
          string = case value
                   when Fixnum
                     value.to_s
                   when Numeric
                     "%.3f" % value
                   when NilClass
                     nil
                   else
                     value.to_s
                   end
          if string
            "#{string}#{suffix}"
          else
            ""
          end
        end

        def size
          to_s.size
        end

        def aligned(width)
          case value
          when Numeric
            to_s.rjust(width)
          else
            to_s.ljust(width)
          end
        end

      end

    end
  end
end
