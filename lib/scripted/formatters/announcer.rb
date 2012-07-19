# encoding: utf-8
require "scripted/formatters/blank"

module Scripted
  module Formatters
    class Announcer < Blank

      def initialize(*)
        super
        @semaphore = Mutex.new
      end

      def start(commands, runner)
        @length = [ 50, commands.max_by { |command| command.name.size }.name.size + 4 ].max
      end

      # wrapped in a synchronize block to prevent asynchronous output clogging the output
      def execute(command)
        @semaphore.synchronize do
          puts ""
          puts cyan("┌" + ("─" * (@length - 2)) + "┐")
          puts "#{cyan("│")} #{command.name.center(@length - 4)} #{cyan("│")}"
          puts cyan("└" + ("─" * (@length - 2)) + "┘")
          puts ""
        end
      end

    end
  end
end
