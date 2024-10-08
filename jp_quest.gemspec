# frozen_string_literal: true

require_relative "lib/jp_quest/version"

Gem::Specification.new do |spec|
  spec.name = "jp_quest"
  spec.version = JpQuest::VERSION
  spec.authors = ["milkeclair"]
  spec.email = ["milkeclair.noreply@gmail.com"]

  spec.summary = "translate to japanese for ftbquest"
  spec.description = "ftbquestを日本語化する"
  spec.homepage = "https://github.com/milkeclair/jp_quest"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/blob/main"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "jp_translator_from_gpt", "~> 1.1.0"
  spec.add_dependency "rainbow", "~> 3.1.1"
  spec.add_dependency "ruby-progressbar", "~> 1.13.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
