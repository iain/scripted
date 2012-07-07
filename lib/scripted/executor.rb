module Scripted
  class Executor

    def self.call(*args)
      executor = new(*args)
      executor.call
      executor
    end

    attr_reader :command, :delegate

    def initialize(command, delegate)
      @command = command
      @delegate = delegate
    end

    def call
      execute!
      delegate.done(self)
      might_halt
    end

    def execute!
      return if executed?
      @running = true
      @success = command.execute!
    ensure
      @executed = true
      @running = false
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

    def might_halt
      if failed? && important?
        @halted = true
        delegate.halt(self)
      end
    end

  end
end
