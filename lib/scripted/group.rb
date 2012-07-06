module Scripted
  class Group

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def define(&block)
      instance_eval &block
    end

    def run(name, &block)
      commands << Command.new(name, &block)
    end

    def commands
      @commands ||= []
    end

  end
end
