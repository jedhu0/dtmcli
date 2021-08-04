# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dtmcli/version'

Gem::Specification.new do |spec|
  spec.name          = "dtmcli"
  spec.version       = Dtmcli::VERSION
  spec.authors       = ["jedhu0"]
  spec.email         = ["huoshiqiu@gmail.com"]
  spec.summary       = %q{ client for dtm }
  spec.description   = %q{ dtm is a lightweight distributed transaction manager }
  spec.homepage      = "https://github.com/jedhu0/dtmcli"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency             'faraday', '~> 1.6.0'

  spec.add_development_dependency "bundler", '>= 2.2.10'
  spec.add_development_dependency 'minitest', '~> 5.8', '>= 5.8.4'
  spec.add_development_dependency 'webmock', '~> 3.13.0'

end
