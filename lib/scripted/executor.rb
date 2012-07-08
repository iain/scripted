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
      @started_at = Time.now
      command.execute!
      @success = true
    rescue Exception => error
      warn "#{error.class}: #{error}"
      warn ""
      error.backtrace.each do |line|
        warn line
      end
      @error = error
      @success = false
    ensure
      @executed = true
      @running = false
      @ended_at = Time.now
      @runtime = @ended_at - @started_at
    end

    attr_reader :started_at, :ended_at, :runtime, :error

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
