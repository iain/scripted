module Scripted
  module Running
    module Execute

      def self.call(command, delegate, logger)
        command.execute!(logger.to_io)
        delegate.success!
      rescue Exception => exception
        logger.exception(command, exception)
        delegate.failed!(exception)
        return false
      end

    end
  end
end
