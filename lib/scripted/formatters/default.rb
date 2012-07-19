module Scripted
  module Formatters
    class Default < Blank

      def initialize(*)
        super
        @semaphore = Mutex.new
      end

      def <<(output)
        out.print output
      end

      def exception(command, exception)
        @semaphore.synchronize do
          puts red("  #{exception.class} during the execution of #{command.name.inspect}:")
          exception.to_s.split("\n").each do |line|
            puts red("    #{line}")
          end
          exception.backtrace.each do |line|
            # remove gem stuff from the backtrace
            unless line.start_with?(File.expand_path("../../../", __FILE__))
              puts cyan("    # #{line}")
            end
          end
        end
      end

    end
  end
end
