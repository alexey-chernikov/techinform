# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "techinform/version"

Gem::Specification.new do |spec|
  spec.name          = 'techinform'
  spec.version       = Techinform::VERSION
  spec.authors       = ['Alexey Chernikov']
  spec.email         = ['alexey.chernikov@gmail.com']

  spec.summary       = %q{Console tools, useful at Techinform}
  spec.description   = %q{Collection of console tools, which is useful for everyday work at Techinform.}
  spec.homepage      = 'https://techinform.pro'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '~> 0.20'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
