module Scripted
  module Output
    class CommandLogger

      attr_reader :logger, :command

      attr_reader :read, :write, :reader

      def initialize(logger, command)

        @logger, @command = logger, command

        @read, @write = IO.pipe

        @reader = Thread.new do
          read.each_char do |char|
            logger.send_to_formatters :each_char, char, command
          end
        end

      end

      def to_io
        write
      end

      def sync
        read.sync
        write.sync
        sleep 0.01
      end

      def close
        sync
        reader.exit
        write.close
        read.close
      end

    end
  end
end
