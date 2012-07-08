module Scripted
  class Command

    attr_reader :name

    def initialize(name, options = {}, &block)
      @name = name
      @options = options
      define(&block) if block
    end

    def define(&block)
      instance_eval &block
    end

    def executable
      @command || Commands::Shell.new(@name)
    end

    def execute!
      executable.execute!
    end

    def sh(command)
      @command = Commands::Shell.new(command)
    end

    def rake(command)
      @command = Commands::Rake.new(command)
    end

    def ruby(&code)
      @command = Commands::Ruby.new(code)
    end

    def important!
      @important = true
    end

    def important?
      @important
    end

    def silent!
      @silent = true
    end

    def silent?
      @silent
    end

    def unimportant?
      @unimportant
    end

    def unimportant!
      @unimportant = true
    end

    def forced!
      @forced = true
    end

    def forced?
      @forced
    end

    def parallel?
      !!@options[:parallel]
    end

    def parallel_id
      @parallel_id ||= (@options[:parallel] || Object.new).object_id
    end

    def run_in_parallel_with?(other)
      other && parallel_id == other.parallel_id
    end

  end
end
