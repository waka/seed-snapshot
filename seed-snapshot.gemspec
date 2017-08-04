# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'seed_snapshot/version'

Gem::Specification.new do |spec|
  spec.name          = 'seed-snapshot'
  spec.version       = SeedSnapshot::VERSION
  spec.authors       = ['yo_waka']
  spec.email         = ['y.wakahara@gmail.com']

  spec.summary       = %q{Easy dump/restore tool for ActiveRecord.}
  spec.description   = %q{Easy dump/restore tool for ActiveRecord.}
  spec.homepage      = 'https://github.com/waka/seed-snapshot'
  spec.license       = 'MIT'

  spec.require_paths = ['lib']
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'erubis'
  spec.add_development_dependency 'mysql2', '>= 0.3', '< 0.4'
  spec.add_runtime_dependency 'activerecord', '>= 4.2'
end
