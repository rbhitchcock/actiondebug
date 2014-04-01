# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'actioncontroller_filter_chain/version'

Gem::Specification.new do |spec|
  spec.name          = "actioncontroller_filter_chain"
  spec.version       = ActionControllerFilterChain::VERSION
  spec.authors       = ["Blake Hitchcock"]
  spec.email         = ["rbhitchcock@gmail.com"]
  spec.summary       = "Show callbacks for an action"
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  #spec.add_runtime_dependency "actioncontroller"
  #spec.add_development_dependency "actioncontroller"
  spec.add_development_dependency "railties"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
