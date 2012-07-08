require 'pty'

module Scripted
  module Formatters

    # The websocket formatter does the following:
    #
    # * open a pseudo terminal (PTY)
    # * use the resulting slave_file as log endpoint
    # * watch the master_io in a thread, which will buffer each character as it comes in
    # * every so often (a fraction of a second), the buffered output will be sent over the wire
    #
    # We use the PTY to be able to capture every char as it is produces, really
    # nice for progress dots. We buffer the output because when a complete line
    # appears at once, we don't want to send the entire thing char for char
    # over the wire.
    class BufferedLogger

      def initialize(delegate)
        @delegate = delegate
        @master_io, @slave_file = PTY.open
        @bufffer = ""
        @reader = Thread.new do
          @master_io.each_char do |char|
            buffer char
          end
        end
        @flusher = Thread.new do
          loop do
            flush
            sleep 0.05
          end
        end
      end

      def to_io
        @slave_file
      end

      def buffer(char)
        @buffer << char
      end

      def flush
        if @buffer != ""
          @delegate << @buffer
          @buffer = ""
        end
      end

      def stop
        @flusher.exit
        @master_io.flush
        @reader.exit
        @slave_file.close
        @master_io.close
        flush
      end


    end
  end
end
