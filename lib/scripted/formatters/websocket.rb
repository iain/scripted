require 'time'
require 'json'
require 'net/http'
require "scripted/formatters/blank"
require "scripted/formatters/human_status"

module Scripted
  module Formatters
    class Websocket < Blank
      include HumanStatus

      def initialize(out, configuration)
        @uri = URI.parse(out)
        super(@uri, configuration)
        @buffers = Hash.new { |h,k| h[k] = "" }
        @flusher = Thread.new do
          loop do
            flush
            sleep 0.1
          end
        end
        publish :action => :initialize
      end

      def each_char(char, command)
        @buffers[command] << char
      end

      def start(commands, runner)
        flush!
        publish :action => :start, :commands => commands.map { |command| command_json(command) }, :runner => runner_json(runner)
      end

      def stop(commands, runner)
        flush!
        publish :action => :stop, :commands => commands.map { |command| command_json(command) }, :runner => runner_json(runner)
      end

      def exception(command, exception)
        flush!
        publish :action => :exception, :command => command_json(command), :exception => exception, :backtrace => exception.backtrace
      end

      def done(command)
        flush!
        publish :action => :done, :command => command_json(command)
      end

      def halted(command)
        flush!
        publish :action => :halted, :command => command_json(command)
      end

      def execute(command)
        flush!
        publish :action => :execute, :command => command_json(command)
      end

      def flush!
        flush
        @buffer = ""
      end

      def flush
        if output != ""
          publish :action => :output, :output => output
        end
      end

      def close
        @flusher.exit
        flush!
        publish :action => :close
      end

      private

      def publish(data)
        message = {:channel => "/scripted", :data => data }
        Net::HTTP.post_form(@uri, :message => message.to_json)
      rescue Errno::ECONNREFUSED
        unless @warned
          warn red("No connection to #{@uri}")
          @warned = true
        end
      end

      def output
        @buffers.map { |command, output| { :command => command_json(command), :output => output } }
      end


      def command_json(command)
        { :name                   => command.name,
          :forced                 => command.forced?,
          :success                => command.success?,
          :halted                 => command.halted?,
          :executed               => command.executed?,
          :only_when_failed       => command.only_when_failed?,
          :parallel_id            => command.parallel_id,
          :failed_but_unimportant => command.failed_but_unimportant?,
          :unimportant            => command.unimportant?,
          :command_type           => command.command.executable.class.to_s,
          :runtime                => command.runtime,
          :started_at             => time(command.started_at),
          :ended_at               => time(command.ended_at),
          :running                => command.running?,
          :id                     => command.object_id,
          :human_status           => human_status(command),
          :status_code            => status_code(command)
        }
      end

      def runner_json(runner)
        { :started_at => time(runner.started_at),
          :ended_at   => time(runner.ended_at),
          :runtime    => runner.runtime,
          :halted     => runner.halted?,
          :running    => runner.running?,
          :executed   => runner.executed?,
          :failed     => runner.failed?
        }
      end

      def time(time)
        if time
          time.utc.iso8601
        else
          time
        end
      end

    end

  end
end
