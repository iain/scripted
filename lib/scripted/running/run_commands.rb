module Scripted
  module Running
    class RunCommands

      attr_reader :logger

      attr_reader :started_at, :ended_at, :runtime

      def initialize(logger)
        @logger = logger
        @executed = false
        @halted = false
        @running = false
      end

      def run(commands)
        logged commands do
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
        end
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

      def halt!(command)
        logger.halted(command)
        @halted = true
      end

      def halted?
        @halted
      end

      def running?
        @running
      end

      def executed?
        @executed
      end

      private

      def logged(commands)
        @started_at = Time.now
        @running = true
        logger.start(commands, self)
        yield
      ensure
        @executed = true
        @running = false
        @ended_at = Time.now
        @runtime = @ended_at - @started_at
        logger.stop(commands, self)
      end

      def should_execute?(command)
        (!halted? || command.forced?) && (!command.only_when_failed? || (failed? && command.only_when_failed?))
      end

    end
  end
end
