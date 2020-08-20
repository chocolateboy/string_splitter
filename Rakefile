# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb'].exclude('test/test_helper.rb')
end

desc 'Check the codebase for style violations'
task :lint do
  sh 'rubocop', '--display-cop-names', '--config', 'resources/rubocop/rubocop.yml'
end

desc 'Open an IRB console with the gem loaded'
task :console do
  Bundler.with_original_env do
    ruby './resources/bin/console.rb'
  end
end

# FIXME this runs after the release!
task :release => %i[rubocop test]

task :default => :test
