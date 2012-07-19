require 'pty'

module Scripted
  module Output
    class CommandLogger

      attr_reader :logger, :command

      attr_reader :master_io, :slave_file, :reader

      def initialize(logger, command)

        @logger, @command = logger, command

        @master_io, @slave_file = PTY.open

        @reader = Thread.new do
          master_io.each_char do |char|
            logger.send_to_formatters :each_char, char, command
          end
        end

      end

      def to_io
        slave_file
      end

      def sync
        master_io.sync
        slave_file.sync
        sleep 0.01
      end

      def close
        sync
        reader.exit
        slave_file.close
        master_io.close
      end

    end
  end
end
