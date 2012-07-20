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
        Scripted.configure(&block) if block
        Scripted.configuration.with_default_config_file!
        Scripted.configuration.load_files
        Scripted.start!(*groups)
      end
    end

  end
end
