# frozen_string_literal: true

require_relative "lib/modpack_localizer/util/version"

Gem::Specification.new do |spec|
  spec.name = "modpack_localizer"
  spec.version = ModpackLocalizer::VERSION
  spec.authors = ["milkeclair"]
  spec.email = ["milkeclair.noreply@gmail.com"]

  spec.summary = "localize minecraft modpack"
  spec.description = "localize minecraft modpack"
  spec.homepage = "https://github.com/milkeclair/modpack_localizer"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.1"

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
  spec.add_dependency "countries"
  spec.add_dependency "dotenv"
  spec.add_dependency "iso-639"
  spec.add_dependency "json"
  spec.add_dependency "rainbow"
  spec.add_dependency "ruby-progressbar"
  spec.add_dependency "rubyzip"
  spec.add_dependency "translation_api"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
