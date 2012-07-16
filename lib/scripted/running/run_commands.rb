module Scripted
  module Running
    class RunCommands

      attr_reader :logger

      def initialize(logger)
        @logger = logger
      end

      def run(commands)
        logger.start(commands)
        commands.group_by(&:parallel_id).each do |parallel_id, parallel_commands|
          threads = []
          parallel_commands.each do |command|
            if should_execute?(command)
              threads << Thread.new do
                command.execute!(self)
              end
            end
          end
          threads.each(&:join)
        end
        logger.stop
      end

      def completed
        @completed ||= []
      end

      def done(command)
        logger.done(command)
        completed << command
      end

      def failed?
        completed.any?(&:failed?)
      end

      def halt!
        logger.halted
        @halted = true
      end

      def halted?
        @halted
      end

      def should_execute?(command)
        (!halted? || command.forced?) && (!command.only_when_failed? || (failed? && command.only_when_failed?))
      end

    end
  end
end
