# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'string_splitter/version'

Gem::Specification.new do |spec|
  spec.name     = 'string_splitter'
  spec.version  = StringSplitter::VERSION
  spec.author   = 'chocolateboy'
  spec.email    = 'chocolate@cpan.org'
  spec.summary  = 'String#split on steroids'
  spec.homepage = 'https://github.com/chocolateboy/string_splitter'
  spec.license  = 'Artistic-2.0'

  spec.files = `git ls-files -z *.md bin lib`.split("\0")
  spec.require_paths = %w[lib]

  # spec.required_ruby_version = '>= 2.3.0'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => 'https://github.com/chocolateboy/string_splitter/issues',
    'changelog_uri'     => 'https://github.com/chocolateboy/string_splitter/blob/master/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/chocolateboy/string_splitter',
  }

  spec.add_runtime_dependency 'values', '~> 1.8'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.11'
  spec.add_development_dependency 'minitest-power_assert', '~> 0.3.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rubocop', '~> 0.54.0'
end
