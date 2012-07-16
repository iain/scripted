module Scripted
  module Running
    class RunCommand

      attr_reader :command, :logger
      attr_reader :started_at, :ended_at, :runtime, :exception, :delegate

      def initialize(command, logger)
        @command = command
        @logger = logger
      end

      def execute!(delegate)
        return if executed?
        @delegate = delegate
        @running = true
        @started_at = Time.now
        logger.execute(self)
        Execute.call(command, self, logger)
      end

      def done
        @executed = true
        @running  = false
        @ended_at = Time.now
        @runtime  = @ended_at - @started_at
        delegate.done(self)
      end

      def success!
        @success = true
        done
      end

      def failed!(exception)
        @success = false
        @exception = exception
        if important?
          @halted = true
          delegate.halt!
        end
        done
      end

      def important?
        command.important?
      end

      def success?
        executed? && !!@success
      end

      def failed?
        executed? && !unimportant? && !@success
      end

      def running?
        !!@running
      end

      def executed?
        !!@executed
      end

      def halted?
        !!@halted
      end

      def unimportant?
        command.unimportant?
      end

      def failed_but_unimportant?
        executed? && !@success && unimportant?
      end

      def parallel_id
        command.parallel_id
      end

      def only_when_failed?
        command.only_when_failed?
      end

      def forced?
        command.forced?
      end

      def name
        command.name
      end

    end
  end
end
