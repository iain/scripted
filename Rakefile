#!/usr/bin/env rake
require "bundler/gem_tasks"

Bundler.setup

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:cucumber)

task :default => [ :spec, :cucumber ]
