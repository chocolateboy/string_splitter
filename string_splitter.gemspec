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

  spec.required_ruby_version = '>= 2.3'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'bug_tracker_uri'   => 'https://github.com/chocolateboy/string_splitter/issues',
    'changelog_uri'     => 'https://github.com/chocolateboy/string_splitter/blob/master/CHANGELOG.md',
    'source_code_uri'   => 'https://github.com/chocolateboy/string_splitter',
  }

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-power_assert', '~> 0.3'
  spec.add_development_dependency 'minitest-reporters', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 13.0'
end
