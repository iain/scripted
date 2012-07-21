require "scripted/command"

module Scripted
  class Group

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def define(&block)
      instance_eval &block if block
    end

    def run(name, &block)
      commands << Command.new(name, :parallel => @parallel, &block)
    end

    def parallel(&block)
      @parallel = Object.new
      yield
      @parallel = nil
    end

    def commands
      @commands ||= []
    end

  end
end
