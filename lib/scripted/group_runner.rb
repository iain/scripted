Thread.abort_on_exception = true

module Scripted
  class GroupRunner
    extend MethodObject

    attr_reader :group, :configuration

    def initialize(group, configuration)
      @group, @configuration = group, configuration
    end

    def command_sets
      group.commands.group_by(&:parallel_id).values
    end

    def call
      command_sets.each do |commands|
        thread_pool = []
        commands.each do |command|
          if continue_with? command
            thread_pool << Thread.new do
              Executor.call(command, self)
            end
          end
        end
        thread_pool.each(&:join)
      end
    end

    def continue_with?(command)
      !halted? || command.forced?
    end

    def completed
      @completed ||= []
    end

    def done(executor)
      completed << executor
    end

    def halt(executor)
      @halted = true
    end

    def halted?
      @halted
    end

    def failed?
      completed.any?(&:failed?)
    end

  end
end
