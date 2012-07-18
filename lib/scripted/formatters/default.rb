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
          warn red("  #{exception.class} during the execution of #{command.name.inspect}:")
          exception.to_s.split("\n").each do |line|
            warn red("    #{line}")
          end
          exception.backtrace.each do |line|
            # remove gem stuff from the backtrace
            unless line.start_with?(File.expand_path("../../../", __FILE__))
              warn cyan("    # #{line}")
            end
          end
        end
      end

      def warn(*args)
        out.puts(*args)
      end

    end
  end
end
