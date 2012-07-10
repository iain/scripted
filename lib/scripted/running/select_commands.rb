module Scripted
  module Running
    class SelectCommands

      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def commands(group_names)
        group_names = [:default] if group_names.empty?
        groups = configuration.groups.values_at(*group_names.map(&:to_sym))
        groups.map { |group| group.commands }.flatten.map { |command| RunCommand.new(command) }
      end

    end
  end
end
