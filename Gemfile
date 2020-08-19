# frozen_string_literal: true

source 'https://rubygems.org'

group :development do
  gem 'rubocop', '~> 0.89' unless ENV['CI']
end

# pull in runtime and test dependencies from string_splitter.gemspec
gemspec development_group: :test
