module Scripted
  class Command

    attr_reader :name

    def initialize(name, &block)
      @name = name
      instance_eval &block if block
    end

    def execute
      @command || @name
    end

    def sh(command)
      @command = command
    end

  end
end
