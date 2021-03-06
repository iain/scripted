# -*- encoding: utf-8 -*-
require File.expand_path('../lib/scripted/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["iain"]
  gem.email         = ["iain@iain.nl"]
  gem.description   = %q{Easily specify which scripts to run, which ones to run in parallel, control their exit status and stream their output to a websockt.}
  gem.summary       = %q{A framework for organizing scripts}
  gem.homepage      = "https://github.com/iain/scripted"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "scripted"
  gem.require_paths = ["lib"]
  gem.version       = Scripted::VERSION

  gem.add_runtime_dependency "childprocess", ">= 0.3.4"

  # For testing
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "cucumber"
  gem.add_development_dependency "aruba"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "fivemat"

  # For the websockets example
  gem.add_development_dependency "thin"
  gem.add_development_dependency "faye"
  gem.add_development_dependency "launchy"
  gem.add_development_dependency "sinatra"
  gem.add_development_dependency "coffee-script"
  gem.add_development_dependency "sass"

end
