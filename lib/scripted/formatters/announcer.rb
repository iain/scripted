# encoding: utf-8
module Scripted
  module Formatters
    class Announcer < Blank

      def initialize(*)
        super
        @semaphore = Mutex.new
      end

      def start(commands)
        @length = [ 50, commands.max_by { |command| command.name.size }.name.size + 4 ].max
      end

      # wrapped in a synchronize block to prevent asynchronous output clogging the output
      def execute(command)
        @semaphore.synchronize do
          out.puts ""
          out.puts cyan("┌" + ("─" * (@length - 2)) + "┐")
          out.puts "#{cyan("│")} #{command.name.center(@length - 4)} #{cyan("│")}"
          out.puts cyan("└" + ("─" * (@length - 2)) + "┘")
          out.puts ""
        end
      end

    end
  end
end
