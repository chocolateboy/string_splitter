# frozen_string_literal: true

require_relative 'test_helper'

# make sure string delimiters are matched verbatim rather than as patterns

describe 'string delimiter' do
  s1 = StringSplitter.new

  it 'handles non-special delimiters' do
    s2 = StringSplitter.new(default_delimiter: ':')

    result = s1.split('foo:bar:baz', ':')
    assert { result == %w[foo bar baz] }

    result = s2.split('foo:bar:baz')
    assert { result == %w[foo bar baz] }

    result = s1.rsplit('foo:bar:baz', ':')
    assert { result == %w[foo bar baz] }

    result = s2.rsplit('foo:bar:baz')
    assert { result == %w[foo bar baz] }
  end

  it 'handles special delimiters' do
    s2 = StringSplitter.new(default_delimiter: '|')

    result = s1.split('foo|bar|baz', '|')
    assert { result == %w[foo bar baz] }

    result = s2.split('foo|bar|baz')
    assert { result == %w[foo bar baz] }

    result = s1.rsplit('foo|bar|baz', '|')
    assert { result == %w[foo bar baz] }

    result = s2.rsplit('foo|bar|baz')
    assert { result == %w[foo bar baz] }
  end
end
