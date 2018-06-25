# frozen_string_literal: true

require_relative 'test_helper'

# make sure string delimiters are treated as strings and not patterns

describe 'string delimiter' do
  s = StringSplitter.new

  it 'handles non-special delimiters' do
    ss = StringSplitter.new(default_delimiter: ':')

    result = s.split('foo:bar:baz', ':')
    assert { result == %w[foo bar baz] }

    result = ss.split('foo:bar:baz')
    assert { result == %w[foo bar baz] }
  end

  it 'handles special delimiters' do
    ss = StringSplitter.new(default_delimiter: '|')

    result = s.split('foo|bar|baz', '|')
    assert { result == %w[foo bar baz] }

    result = ss.split('foo|bar|baz')
    assert { result == %w[foo bar baz] }
  end
end
