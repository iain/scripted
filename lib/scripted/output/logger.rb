require 'active_support/core_ext/string/inflections'
require 'scripted/output/command_logger'

module Scripted
  module Output
    class Logger

      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
        if block_given?
          begin
            yield self
          ensure
            close
          end
        end
      end

      def command_loggers
        @command_loggers ||= Hash.new { |h,k| h[k] = CommandLogger.new(self, k) }
      end

      def self.delegate_to_formatters(name)
        define_method(name) { |*args, &block|
          sync
          send_to_formatters(name, *args, &block)
        }
      end

      delegate_to_formatters :stop
      delegate_to_formatters :done
      delegate_to_formatters :halted
      delegate_to_formatters :execute
      delegate_to_formatters :exception

      def start(commands, runner)
        # create all the command loggers
        commands.each { |c| command_loggers[c] }
        sync
        send_to_formatters :start, commands, runner
      end

      def to_io(command)
        command_loggers[command].to_io
      end

      def send_to_formatters(*args, &block)
        formatters.each { |formatter| formatter.send(*args, &block) }
      end

      private

      def sync
        command_loggers.each { |c, l| l.sync }
      end

      def close
        command_loggers.each { |c, l| l.close }
        send_to_formatters :close
      end

      def formatters
        @formatters ||= build_formatters
      end

      def build_formatters
        formatter_names = configuration.formatters
        if formatter_names.empty?
          formatter_names = [ {:name => "default"} ]
        end
        formatters = formatter_names.uniq { |fn| fn[:name] }.map do |formatter|
          find_formatter(formatter[:name]).new(formatter.fetch(:out, STDERR), configuration)
        end
        formatters
      end

      def find_formatter(name)
        name = name.to_s
        if name =~ /^[A-Z]/
          require name.underscore
          name.constantize
        else
          require "scripted/formatters/#{name}"
          "Scripted::Formatters::#{name.camelize}".constantize
        end
      end

    end
  end
end
