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

  gem.add_runtime_dependency "childprocess"

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "cucumber"
  gem.add_development_dependency "aruba"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "ruby_gntp"
  gem.add_development_dependency "fivemat"

end
