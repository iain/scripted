module Scripted
  module Commands
    class Ruby

      def initialize(code)
        @code = code
      end

      def execute!
        @code.call
      end

    end
  end
end
