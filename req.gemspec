# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'req/version'

Gem::Specification.new do |spec|
  spec.name          = "req"
  spec.version       = Req::VERSION
  spec.authors       = ["wenjun.yan"]
  spec.email         = ["mylastnameisyan@gmail.com"]
  spec.description   = %q{an easy way to deal with simple http request}
  spec.summary       = %q{FORK ME => Req["https://api.github.com/repo/v2e4lisp/req/forks"].auth("user", "pass").post }
  spec.homepage      = "https://github.com/v2e4lisp/req"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mime-types"
  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'sinatra'
  spec.add_development_dependency 'sinatra-contrib'
end
