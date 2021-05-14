# frozen_string_literal: true

require_relative "lib/structured_csv/version"

Gem::Specification.new do |spec|
  spec.name          = "structured_csv"
  spec.version       = StructuredCsv::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Library to process structured CSV files"
  spec.description   = "Library to process structured CSV files"
  spec.homepage      = "https://open.ribose.com"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/riboseinc/structured_csv"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency "csv", "~> 3.1"
  spec.add_dependency "pathname", "~> 0.1"
  spec.add_dependency "yaml", "~> 0.1"

  spec.add_development_dependency "byebug", "~> 11.1"
  spec.add_development_dependency "guard", "~> 2.17"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
  spec.add_development_dependency "rubocop", "~> 1.14.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
end
