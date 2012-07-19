require 'pty'
require 'active_support/core_ext/string/inflections'

module Scripted
  class Logger

    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
      @master_io, @slave_file = PTY.open
      @reader = Thread.new do
        @master_io.each_char do |char|
          self << char
        end
      end
      if block_given?
        begin
          yield self
        ensure
          close
        end
      end
    end

    def self.delegate_to_formatters(name)
      define_method(name) { |*args, &block|
        sync
        send_to_formatters(name, *args, &block)
      }
    end

    delegate_to_formatters :start
    delegate_to_formatters :stop
    delegate_to_formatters :done
    delegate_to_formatters :halted
    delegate_to_formatters :execute
    delegate_to_formatters :exception

    def <<(output)
      send_to_formatters :<<, output
    end

    def to_io
      @slave_file
    end

    def send_to_formatters(*args, &block)
      formatters.each { |formatter| formatter.send(*args, &block) }
    end

    def close
      sync
      @reader.exit
      @slave_file.close
      @master_io.close
      send_to_formatters :close
    end

    private

    def sync
      @master_io.sync
      @slave_file.sync
      sleep 0.01
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
