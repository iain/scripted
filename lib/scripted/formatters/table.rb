# encoding: utf-8

require "scripted/formatters/blank"
require 'scripted/formatters/human_status'

module Scripted
  module Formatters
    class Table < Blank
      include HumanStatus

      def stop(commands)
        report_lines << [ Column["Command"], Column["Runtime"], Column["Status"] ]
        commands.each do |command|
          report_lines << [ Column[command.name], Column[command.runtime, "s"], Column[human_status(command)] ]
        end
        widths = report_lines.transpose.map { |line| line.max_by(&:size).size }
        header = report_lines.shift
        puts ""
        puts ""
        puts separator(widths, "┌", "┬", "┐")
        puts report_line(header, widths)
        puts separator(widths, "├", "┼", "┤")
        report_lines.each do |line|
          puts report_line(line, widths)
        end
        puts separator(widths, "└", "┴", "┘")
      end

      private

      def separator(widths, left, middle, right)
        cyan(left) + widths.map { |width| (cyan("─") * (width + 2)).force_encoding('utf-8') }.join(cyan(middle)) + cyan(right)
      end

      def report_line(line, widths)
        cyan("│ ") + line.zip(widths).map { |(column, width)| column.aligned(width) }.join(cyan(" │ ")) + cyan(" │")
      end

      def report_lines
        @report_lines ||= []
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
