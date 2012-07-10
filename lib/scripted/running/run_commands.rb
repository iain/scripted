module Scripted
  module Running
    class RunCommands

      def initialize(configuration)
        @configuration = configuration
      end

      def run(commands)
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

      def completed
        @completed ||= []
      end

      def done(command)
        completed << command
      end

      def failed?
        completed.any?(&:failed?)
      end

      def halt!
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
