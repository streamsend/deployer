# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deployer/version'

Gem::Specification.new do |spec|
  spec.name          = "deployer"
  spec.version       = Deployer::VERSION
  spec.authors       = ["Kevin Fries", "Ed Gibbs", "John Gedeon"]
  spec.email         = ["kfries@ezpublishing.com", "edgibbs@streamsend.com", "jgedeon@ezpublishing.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "trollop"

  spec.add_runtime_dependency "tracker_api", "~> 0.2.0"
  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
