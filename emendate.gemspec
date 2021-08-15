# frozen_string_literal: true

require_relative 'lib/emendate/version'

Gem::Specification.new do |spec|
  spec.name          = 'emendate'
  spec.version       = Emendate::VERSION
  spec.authors       = ['Kristina Spurgin']
  spec.email         = ['kristina.spurgin@lyrasis.org']

  spec.summary       = %q{Lexer, parser, transformer for messy date metadata}
  spec.homepage      = 'https://github.com/kspurgin/emendate'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.2')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kspurgin/emendate'
  spec.metadata['changelog_uri'] = 'https://github.com/kspurgin/emendate'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aasm'
end
