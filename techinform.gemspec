# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "techinform/version"

Gem::Specification.new do |spec|
  spec.name          = 'techinform'
  spec.version       = Techinform::VERSION
  spec.authors       = ['Alexey Chernikov']
  spec.email         = ['alexey@chernikov.online']

  spec.summary       = %q{Console tools, useful at Techinform}
  spec.description   = %q{Collection of console tools, which is useful for everyday work at Techinform Soft ( https://techinform.dev )}
  spec.homepage      = 'https://techinform.dev'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/alexey-chernikov/techinform"
    spec.metadata["changelog_uri"] = "https://github.com/alexey-chernikov/techinform/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.licenses      = ['MIT']

  spec.add_dependency 'thor', '~> 0.20'
  spec.add_dependency 'highline', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0.1'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
