require 'scripted'

require 'rake'
require 'rake/tasklib'

module Scripted
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    def initialize(name, *groups, &block)
      groups = [:default] if groups.empty?
      unless Rake.application.last_description
        desc "Run scripted groups: #{groups.map(&:to_s).join(', ')}"
      end
      task name do
        config = Scripted.configuration
        config.evaluate(&block) if block
        config.with_default_config_file!
        config.load_files
        Scripted.start!(config, *groups)
      end
    end

  end
end
