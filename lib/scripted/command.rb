module Scripted
  class Command

    attr_reader :name

    def initialize(name, &block)
      @name = name
      define(&block) if block
    end

    def define(&block)
      instance_eval &block
    end

    def execute
      @command ||= Commands::Shell.new(@name)
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

  end
end
