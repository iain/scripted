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
          find_formatter(formatter.fetch(:name)).new(formatter.fetch(:out, STDERR), configuration)
        end
        formatters
      end

      def find_formatter(name)
        built_in_formatter(name) || custom_formatter(name)
      end

      def built_in_formatter(formatter_ref)
        case formatter_ref.to_s.downcase
        when 'announcer', 'a', 'ann', 'announce'
          require 'scripted/formatters/announcer'
          Scripted::Formatters::Announcer
        when 'blank'
          require 'scripted/formatters/blank'
          Scripted::Formatters::Blank
        when 'default', 'd'
          require 'scripted/formatters/default'
          Scripted::Formatters::Default
        when 'table', 't'
          require 'scripted/formatters/table'
          Scripted::Formatters::Table
        when 'stats', 's', 'stat'
          require 'scripted/formatters/stats'
          Scripted::Formatters::Stats
        when 'websockets', 'w', 'web', 'websocket'
          require 'scripted/formatters/websocket'
          Scripted::Formatters::Websocket
        end
      end

      def custom_formatter(formatter_ref)
        if Class === formatter_ref
          formatter_ref
        elsif string_const?(formatter_ref)
          begin
            eval(formatter_ref)
          rescue NameError
            require path_for(formatter_ref)
            eval(formatter_ref)
          end
        end
      end

      def string_const?(str)
        str.is_a?(String) && /\A[A-Z][a-zA-Z0-9_:]*\z/ =~ str
      end

      def path_for(const_ref)
        underscore(const_ref)
      end

      # activesupport/lib/active_support/inflector/methods.rb, line 48
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end

    end
  end
end
