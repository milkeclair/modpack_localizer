# frozen_string_literal: true

class RakeHelper
  GITHUB_PACKAGES_PUSH_COMMAND =
    "gem push --key github --host https://rubygems.pkg.github.com/milkeclair " \
    "pkg/jp_quest-#{JpQuest::VERSION}.gem".freeze

  RUBYGEMS_PUSH_COMMAND =
    "gem push --host https://rubygems.org " \
    "pkg/jp_quest-#{JpQuest::VERSION}.gem".freeze

  def self.init_rake_tasks
    RSpec::Core::RakeTask.new(:spec) { |task| task.verbose = false }
    RuboCop::RakeTask.new
    YARD::Rake::YardocTask.new
  end

  def self.build_gem
    abort("gemのビルドに失敗しました") unless system("rake build")
  end

  def self.push_to_github_packages
    abort("githubへのgemのpushに失敗しました") unless system(GITHUB_PACKAGES_PUSH_COMMAND)
  end

  def self.push_to_rubygems
    abort("rubygemsへのgemのpushに失敗しました") unless system(RUBYGEMS_PUSH_COMMAND)
  end
end
