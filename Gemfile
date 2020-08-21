# frozen_string_literal: true

source 'https://rubygems.org'

unless ENV['CI']
  group :development do
    gem 'irb', '~> 1.2' # XXX work around Arch Linux's broken ruby packaging

    # "2.3-compatible analysis was dropped after version 0.81."
    # gem 'rubocop', '0.81'
    gem 'rubocop', '~> 0.89'
  end
end

# pull in runtime and test dependencies from string_splitter.gemspec
gemspec development_group: :test
