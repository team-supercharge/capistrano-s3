# encoding: utf-8
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'capistrano/s3/version'

Gem::Specification.new do |s|
  s.authors       = ['Jean-Philippe Doyle','Josh Delsman','Aleksandrs Ļedovskis','Douglas Jarquin', 'Amit Barvaz', 'Jan Lindblom']
  s.email         = ['jeanphilippe.doyle@hooktstudios.com', 'aleksandrs@ledovskis.lv']
  s.description   = 'Enables static websites deployment to Amazon S3 website buckets using Capistrano.'
  s.summary       = 'Build and deploy a static website to Amazon S3'
  s.homepage      = 'http://github.com/hooktstudios/capistrano-s3'
  s.licenses      = ['MIT']
  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = 'capistrano-s3'
  s.require_paths = ['lib']
  s.version       = Capistrano::S3::VERSION
  s.cert_chain  = ['certs/j15e.pem']
  s.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  # Min rubies
  s.required_ruby_version = ">= 2.1"

  # Gem dependencies
  s.add_runtime_dependency 'aws-sdk',    '~> 1.11'
  s.add_runtime_dependency 'capistrano', '>= 2'
  s.add_runtime_dependency 'mime-types', '~> 1.23'
  s.add_runtime_dependency 'net-ssh',    '~> 2.9'

  # Development dependencies
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'gem-release'
end
