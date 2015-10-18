# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_galapagos_ci/version'

Gem::Specification.new do |spec|
  spec.name          = "rails-galapagos-ci"
  spec.version       = RailsGalapagosCi::VERSION
  spec.authors       = ["koudenpa"]
  spec.email         = ["koudenpa@hotmail.com"]

  spec.summary       = %q{Ruby on Rails で日本的なガラパゴスなCIを行うためのユーティリティ(を作っていく予定)です。}
  spec.homepage      = "https://github.com/7474/rails-galapagos-ci"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency 'rails'
  spec.add_runtime_dependency 'rails-erd'
  spec.add_runtime_dependency 'migration_comments'
end
