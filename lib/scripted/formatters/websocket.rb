require "socket"
require 'json'
require 'net/http'
require "scripted/formatters/blank"

module Scripted
  module Formatters
    class Websocket < Blank

      def initialize(out, configuration)
        @uri = URI.parse(out)
        super(@uri, configuration)
        @buffer = ""
        @old_buffer = ""
        @flusher = Thread.new do
          loop do
            flush
            sleep 0.1
          end
        end
        publish :action => :initialize
      end

      def each_char(char, command)
        @buffer << char
      end

      def publish(data)
        message = {:channel => "/scripted", :data => data }
        Net::HTTP.post_form(@uri, :message => message.to_json)
      rescue Errno::ECONNREFUSED
        unless @warned
          warn red("No connection to #{@uri}")
          @warned = true
        end
      end

      def start(commands, runner)
        flush!
        publish :action => :start, :commands => commands
      end

      def stop(commands, runner)
        flush!
        publish :action => :stop, :commands => commands
      end

      def exception(command, exception)
        flush!
        publish :action => :exception, :command => command, :exception => exception, :backtrace => exception.backtrace
      end

      def done(command)
        flush!
        publish :action => :done, :command => command
      end

      def halted(command)
        flush!
        publish :action => :halted, :command => command
      end

      def execute(command)
        flush!
        publish :action => :execute, :command => command
      end

      def flush!
        flush
        @buffer = ""
      end

      def flush
        if @buffer != ""
          publish :action => :output, :output => @buffer
        end
      end

      def close
        @flusher.exit
        flush!
        publish :action => :close
      end

    end

  end
end
