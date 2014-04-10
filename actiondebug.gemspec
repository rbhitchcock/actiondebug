# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'actiondebug/version'

Gem::Specification.new do |spec|
  spec.name          = "actiondebug"
  spec.version       = ActionDebug::VERSION
  spec.authors       = ["Blake Hitchcock"]
  spec.email         = ["rbhitchcock@gmail.com"]
  spec.summary       = "A gem to show which *_filters affect your Rails controllers"
  spec.description   = <<-EOF
    actiondebug is a utility that can give you more insight
    into the structure of your Rails application. It can show all filters that
    a controller is using, grouped by action. It can also report which actions
    skip a given filter. Its extendability is essentially endless. Great tool
    for security researchers and developers alike.
  EOF
  spec.homepage      = "https://github.com/rbhitchcock/actiondebug"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
