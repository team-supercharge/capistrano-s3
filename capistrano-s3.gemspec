# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.authors       = ['Jean-Philippe Doyle','Josh Delsman','Aleksandrs Ļedovskis','Douglas Jarquin']
  s.email         = ['jeanphilippe.doyle@hooktstudios.com']
  s.description   = 'Enables static websites deployment to Amazon S3 website buckets using Capistrano.'
  s.summary       = 'Build and deploy a static website to Amazon S3'
  s.homepage      = 'http://github.com/hooktstudios/capistrano-s3'
  s.licenses      = ['MIT']
  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = 'capistrano-s3'
  s.require_paths = ['lib']
  s.version       = '0.2.6'
  s.cert_chain  = ['certs/j15e.pem']
  s.signing_key = File.expand_path('~/.gem/private_key.pem') if $0 =~ /gem\z/

  # Gem dependencies
  s.add_dependency 'aws-sdk'
  s.add_dependency 'capistrano'
  s.add_dependency 'mime-types'

  s.add_development_dependency 'rake'
end
