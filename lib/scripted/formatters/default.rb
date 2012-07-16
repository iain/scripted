module Scripted
  module Formatters
    class Default < Blank

      def initialize(*)
        super
        @exceptions = []
      end

      def <<(output)
        out.print output
      end

      def exception(command, exception)
        @exceptions << [ command, exception ]
      end

      def close
        @exceptions.each do |(command, exception)|
          warn red("#{exception.class} during the execution of #{command.name}: #{exception}")
          exception.backtrace.each do |line|
            # remove gem stuff from the backtrace
            unless line.start_with?(File.expand_path("../../../", __FILE__))
              warn gray("  - #{line}")
            end
          end
        end
      end

      def warn(*args)
        out.flush
        out.puts(*args)
      end

    end
  end
end
