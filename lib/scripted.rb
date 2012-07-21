Thread.abort_on_exception = true

require "scripted/error"
require "scripted/version"
require "scripted/output/logger"
require "scripted/running/select_commands"
require "scripted/running/run_commands"
require "scripted/configuration"

module Scripted

  def self.start!(configuration, *group_names)
    Output::Logger.new(configuration) do |logger|
      select_commands = Running::SelectCommands.new(configuration, logger)
      commands = select_commands.commands(group_names)
      run_commands = Running::RunCommands.new(logger)
      run_commands.run(commands)
      raise RunningFailed, "One or more commands have failed" if run_commands.failed?
    end
  end

  def self.configuration
    Configuration.new
  end

end
