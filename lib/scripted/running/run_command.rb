module Scripted
  module Running
    class RunCommand

      attr_reader :command
      attr_reader :started_at, :ended_at, :runtime, :exception, :delegate

      def initialize(command)
        @command = command
      end

      def execute!(delegate)
        return if executed?
        @delegate = delegate
        @running = true
        @started_at = Time.now
        Execute.call(command, self)
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

    end
  end
end
