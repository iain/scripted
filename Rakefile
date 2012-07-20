#!/usr/bin/env rake
require "bundler/gem_tasks"

Bundler.setup

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber)

require 'scripted/rake_task'
Scripted::RakeTask.new(:scripted)

task :default => [:scripted]

namespace :examples do

  desc "Run the websockets example (really cool)"
  Scripted::RakeTask.new(:websockets) do
    config_file "examples/websockets.rb"
  end

  desc "Run the parallel example"
  Scripted::RakeTask.new(:parallel) do
    config_file "examples/parallel.rb"
  end

end
