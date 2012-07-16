require 'pty'

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
      define_method name do |*args, &block|
        send_to_formatters(name, *args, &block)
      end
    end

    delegate_to_formatters :start
    delegate_to_formatters :stop
    delegate_to_formatters :done
    delegate_to_formatters :halted
    delegate_to_formatters :execute
    delegate_to_formatters :exception
    delegate_to_formatters :<<

    def to_io
      @slave_file
    end

    def send_to_formatters(*args, &block)
      formatters.each { |formatter| formatter.send(*args, &block) }
    end

    def close
      @master_io.flush
      sleep 0.1 # give the @reader thread time to process the flush
      @reader.exit
      @slave_file.close
      @master_io.close
      send_to_formatters :close
    end

    private

    def formatters
      @formatters ||= build_formatters
    end

    def build_formatters
      formatters = configuration.formatters.map do |formatter|
        find_formatter(formatter[:name]).new(formatter[:out] || STDERR)
      end
      formatters = [ Formatters::Default.new(STDERR) ] if formatters.empty?
      formatters
    end

    def find_formatter(name)
      { "table" => Formatters::Table,
        "default" => Formatters::Default
      }[name]
    end

  end
end
