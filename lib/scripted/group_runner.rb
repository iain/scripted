module Scripted
  class GroupRunner
    extend MethodObject

    attr_reader :group, :configuration

    def initialize(group, configuration)
      @group, @configuration = group, configuration
    end

    def call
      group.commands.each do |command|
        if !halted? || command.forced?
          Executor.call(command, self)
        end
      end
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
