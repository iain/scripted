Thread.abort_on_exception = true

require "scripted/error"
require "scripted/version" unless defined?(Scripted::VERSION)
require "scripted/configuration"
require "scripted/runner"

module Scripted

  # Runs scripted.
  #
  # You can pass a configuration with group names,
  # or you can pass a block, which will be the ad-hoc configuration.
  def self.run(configuration = nil, *group_names, &block)
    raise NotConfigured if configuration.nil? && block.nil?
    config = configuration || configure(&block)
    Runner.start!(config, *group_names)
  end

  # Configure scripted, returning a configuration which can be run later.
  # Optionally pass a block to configure in place.
  def self.configure(&block)
    config = Configuration.new
    config.evaluate(&block) if block_given?
    config
  end

end
