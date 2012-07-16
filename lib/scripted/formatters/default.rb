module Scripted
  module Formatters
    class Default < Blank

      def <<(output)
        out.print output
      end

      def exception(command, exception)
        warn "#{exception.class} during the execution of #{command.name}: #{exception}"
        warn ""
        exception.backtrace.each do |line|
          warn line
        end
      end

    end
  end
end
