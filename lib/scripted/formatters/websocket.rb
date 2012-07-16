module Scripted
  module Formatters

    class Websocket

      def initialize(url)
        @url = url
        @buffer = BufferedLogger.new(self)
        if block_given?
          begin
            yield self
          ensure
            @buffer.stop
          end
        end
      end

      def to_io
        @buffer.to_io
      end

      # TODO
      def <<(output)
        puts output
      end

    end
  end
end
