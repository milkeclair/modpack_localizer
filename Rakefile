# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "yard"
require_relative "rake_helper"

desc "analysis"
task :analysis do
  sh "bundle install"

  RakeHelper.init_rake_tasks

  puts "--- rspec ---"
  Rake::Task[:spec].invoke

  puts "--- rubocop ---"
  Rake::Task[:rubocop].invoke

  puts "--- yard ---"
  Rake::Task[:yard].invoke
end

desc "push to github packages and rubygems"
task :push do
  sh "bundle install"

  puts "--- build ---"
  RakeHelper.build_gem

  puts "--- push to github packages ---"
  RakeHelper.push_to_github_packages

  puts "--- push to rubygems ---"
  RakeHelper.push_to_rubygems
end

task default: :analysis
