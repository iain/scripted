module Scripted
  module Running
    module Execute

      def self.call(command, delegate)
        command.execute!
        delegate.success!
      rescue Exception => exception
        delegate.failed!(exception)
        log exception
        return false
      end

      def self.log(exception)
        warn "#{exception.class}: #{exception}"
        warn ""
        exception.backtrace.each do |line|
          warn line
        end
      end

    end
  end
end
