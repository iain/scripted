# -*- encoding: utf-8 -*-
require File.expand_path('../lib/scripted/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["iain"]
  gem.email         = ["iain@iain.nl"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "scripted"
  gem.require_paths = ["lib"]
  gem.version       = Scripted::VERSION

  gem.add_development_dependency "rspec",        "~> 2.11"
  gem.add_development_dependency "cucumber",     "~> 1.2"
  gem.add_development_dependency "aruba",        "~> 0.4"
  gem.add_development_dependency "rake",         "~> 0.9"
  gem.add_development_dependency "guard-rspec",  "~> 1.1"
  gem.add_development_dependency "ruby_gntp",    "~> 0.3"
end
