module Scripted
  module Running
    module Execute

      def self.call(command, delegate, logger)
        command.execute!(logger.to_io(delegate))
        delegate.success!
      rescue Exception => exception
        logger.exception(delegate, exception)
        delegate.failed!(exception)
        return false
      end

    end
  end
end
