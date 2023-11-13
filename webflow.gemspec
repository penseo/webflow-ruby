lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webflow/version'

Gem::Specification.new do |spec|
  spec.name          = 'webflow-ruby'
  spec.version       = Webflow::VERSION
  spec.authors       = %w[phoet vfonic]
  spec.email         = ['phoetmail@googlemail.com']

  spec.summary       = 'Webflow API bindings for Ruby'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/penseo/webflow-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'http'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.7.0'
end
