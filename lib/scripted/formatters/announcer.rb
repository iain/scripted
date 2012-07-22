# encoding: utf-8
require "scripted/formatters/blank"
require 'thread'

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
          puts cyan("┌" + force_encoding("─" * (@length - 2)) + "┐")
          puts "#{cyan("│")} #{command.name.center(@length - 4)} #{cyan("│")}"
          puts cyan("└" + force_encoding("─" * (@length - 2)) + "┘")
          puts ""
        end
      end

      def force_encoding(text)
        if text.respond_to?(:force_encoding)
          text.force_encoding('utf-8')
        else # ruby 1.8
          text
        end
      end

    end
  end
end
