# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webflow/version'

Gem::Specification.new do |spec|
  spec.name          = "webflow-ruby"
  spec.version       = Webflow::VERSION
  spec.authors       = ["phoet"]
  spec.email         = ["phoetmail@googlemail.com"]

  spec.summary       = %q{Webflow API bindings for Ruby}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/phoet/webflow-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "typhoeus"
  spec.add_dependency "oj"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
