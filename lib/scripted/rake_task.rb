require 'scripted'

require 'rake'
require 'rake/tasklib'

module Scripted
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined?(::Rake::DSL)

    def initialize(name, *group_names, &block)
      group_names = [:default] if group_names.empty?
      unless Rake.application.last_description
        desc "Run scripted groups: #{group_names.map(&:to_s).join(', ')}"
      end
      task name do
        config = Scripted.configure(&block)
        config.with_default_config_file!
        config.load_files
        Scripted.run(config, *group_names)
      end
    end

  end
end
