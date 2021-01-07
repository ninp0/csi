# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csi/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= #{File.read('.ruby-version')}"
  spec.name = 'csi'
  spec.version = CSI::VERSION
  spec.authors = ['Jacob Hoopes']
  spec.email = ['jake.hoopes@gmail.com']
  spec.summary = 'Automated Security Testing for CI/CD Pipelines & Beyond'
  spec.description = 'https://github.com/0dayinc/csi/README.md'
  spec.homepage = 'https://github.com/0dayinc/csi'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'bundler/gem_tasks'

  spec.add_development_dependency 'rake'

  spec.add_development_dependency 'rdoc'

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec/core/rake_task'
end
