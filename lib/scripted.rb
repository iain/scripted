require "scripted/error"
require "scripted/version"
require "scripted/group"
require "scripted/command"
require "scripted/runner"
require "scripted/configuration"

require "scripted/commands/shell"
require "scripted/commands/rake"
require "scripted/commands/ruby"

module Scripted

  def self.start!
  end

  # Configure it, just like in the `scripted.rb` file.
  def self.configure(*args, &block)
    configuration.evaluate(*args, &block)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end


end
