# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'redis-store-testing'
  spec.version       = '0.0.1'
  spec.authors       = ['Luca Guidi']
  spec.email         = ['me@lucaguidi.com']
  spec.description   = %q{redis-store testing}
  spec.summary       = %q{Common redis-store testing utilities}
  spec.homepage      = 'http://redis-store.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['tasks']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
