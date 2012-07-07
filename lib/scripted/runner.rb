module Scripted
  class Runner
    extend MethodObject

    attr_reader :group_names, :configuration

    def initialize(group_names, configuration)
      @group_names, @configuration = group_names, configuration
    end

    def call
      groups.each do |group_runner|
        group_runner.call
      end
    end

    def selected_group_names
      if group_names.empty?
        [:default]
      else
        group_names
      end
    end

    def groups
      @groups ||= configuration.select_groups(*selected_group_names).map do |group|
        GroupRunner.new(group, configuration)
      end
    end

    def failed?
      groups.any?(&:failed?)
    end

  end
end
