# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ["Jean-Philippe Doyle","Josh Delsman"]
  gem.email         = ["jeanphilippe.doyle@hooktstudios.com"]
  gem.description   = "Using Ruby and Capistrano, build and deploy a static website to Amazon S3"
  gem.summary       = "Using Ruby and Capistrano, build and deploy a static website to Amazon S3"
  gem.homepage      = "http://github.com/hooktstudios/capistrano-s3"
  gem.licenses      = ["MIT"]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "capistrano-s3"
  gem.require_paths = ["lib"]
  gem.version       = "0.2.1"

  # Gem dependencies
  gem.add_dependency("aws-sdk")
  gem.add_dependency("capistrano")
  gem.add_dependency("mime-types")
end
