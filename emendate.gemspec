# frozen_string_literal: true

require_relative "lib/emendate/version"

Gem::Specification.new do |spec|
  spec.name = "emendate"
  spec.version = Emendate::VERSION
  spec.authors = ["Kristina Spurgin"]
  spec.email = ["kristina.spurgin@lyrasis.org"]

  spec.summary = "Lexer, parser, transformer for messy date metadata"
  spec.homepage = "https://github.com/kspurgin/emendate"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.3")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kspurgin/emendate"
  spec.metadata["changelog_uri"] = "https://github.com/kspurgin/emendate"

  # Specify which files should be added to the gem when it is released.
  # rubocop:todo Layout/LineLength
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # rubocop:enable Layout/LineLength
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 6"
  spec.add_dependency "dry-configurable"
  spec.add_dependency "dry-monads"
  spec.add_dependency "dry-validation"

  spec.add_development_dependency "debug"
end
