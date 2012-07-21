Thread.abort_on_exception = true

require "scripted/error"
require "scripted/version"
require "scripted/group"
require "scripted/command"
require "scripted/configuration"

require "scripted/commands/shell"
require "scripted/commands/rake"
require "scripted/commands/ruby"

require "scripted/running/select_commands"
require "scripted/running/run_commands"
require "scripted/running/run_command"
require "scripted/running/execute"

require "scripted/output/logger"

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
