require "scripted/error"
require "scripted/version"
require "scripted/method_object"
require "scripted/group"
require "scripted/command"
require "scripted/runner"
require "scripted/group_runner"
require "scripted/configuration"
require "scripted/executor"

require "scripted/commands/shell"
require "scripted/commands/rake"
require "scripted/commands/ruby"

module Scripted

  def self.start!(*group_names)
    runner = Runner.call(group_names, configuration)
    raise RunningFailed, "One or more commands have failed" if runner.failed?
  end

  # Configure it, just like in the `scripted.rb` file.
  def self.configure(*args, &block)
    configuration.evaluate(*args, &block)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

end
