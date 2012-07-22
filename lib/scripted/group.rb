require "scripted/command"

module Scripted
  class Group

    attr_reader :name

    def initialize(name)
      @name = name
      @parallel = false
      @parallel_id = (object_id ** 2)
    end

    def define(&block)
      instance_eval &block if block
    end

    def run(name, &block)
      next_parallel_id unless in_parallel?
      commands << Command.new(name, :parallel_id => parallel_id, &block)
    end

    def parallel(&block)
      @parallel = true
      yield
      @parallel = false
      next_parallel_id
    end

    def commands
      @commands ||= []
    end

    private

    def parallel_id
      @parallel_id
    end

    def next_parallel_id
      @parallel_id += 1
    end

    def in_parallel?
      @parallel
    end

  end
end
