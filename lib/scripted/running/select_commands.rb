require "scripted/running/run_command"

module Scripted
  module Running
    class SelectCommands

      attr_reader :configuration, :logger

      def initialize(configuration, logger)
        @configuration = configuration
        @logger = logger
      end

      def commands(group_names)
        group_names = [:default] if group_names.empty?
        groups = configuration.groups.values_at(*group_names.map(&:to_sym))
        groups.map { |group| group.commands }.flatten.map { |command| RunCommand.new(command, logger) }
      end

    end
  end
end
