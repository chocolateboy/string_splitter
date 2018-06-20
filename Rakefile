# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb'].exclude('test/test_helper.rb')
end

desc 'Check the codebase for style violations'
task :rubocop do
  sh 'rubocop', '--display-cop-names', '--config', 'resources/rubocop/rubocop.yml'
end

# FIXME this runs after the release!
task :release => %i[rubocop test]

task :default => :test
