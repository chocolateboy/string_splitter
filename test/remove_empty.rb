# frozen_string_literal: true

require_relative 'test_helper'

# confirm that the :remove_empty_fields option removes empty fields

describe 'remove_empty' do
  s1 = StringSplitter.new # default: remove_empty_fields: false
  s2 = StringSplitter.new(remove_empty_fields: false) # same as 1 but explicit
  s3 = StringSplitter.new(remove_empty_fields: true)

  it 'removes leading empty fields' do
    string = ':foo:bar:baz:quux'

    result = s1.split(string, ':')
    assert { result == ['', 'foo', 'bar', 'baz', 'quux'] }

    result = s2.split(string, ':')
    assert { result == ['', 'foo', 'bar', 'baz', 'quux'] }

    result = s3.split(string, ':') { true }
    assert { result == %w[foo bar baz quux] }

    result = s1.rsplit(string, ':')
    assert { result == ['', 'foo', 'bar', 'baz', 'quux'] }

    result = s2.rsplit(string, ':')
    assert { result == ['', 'foo', 'bar', 'baz', 'quux'] }

    result = s3.rsplit(string, ':') { true }
    assert { result == %w[foo bar baz quux] }
  end

  it 'removes trailing empty fields' do
    string = 'foo:bar:baz:quux:'

    result = s1.split(string, ':')
    assert { result == ['foo', 'bar', 'baz', 'quux', ''] }

    result = s2.split(string, ':')
    assert { result == ['foo', 'bar', 'baz', 'quux', ''] }

    result = s3.split(string, ':')
    assert { result == %w[foo bar baz quux] }

    result = s1.rsplit(string, ':')
    assert { result == ['foo', 'bar', 'baz', 'quux', ''] }

    result = s2.rsplit(string, ':')
    assert { result == ['foo', 'bar', 'baz', 'quux', ''] }

    result = s3.rsplit(string, ':')
    assert { result == %w[foo bar baz quux] }
  end

  it 'removes embedded empty fields' do
    string = 'foo:bar::baz:quux'

    result = s1.split(string, ':')
    assert { result == ['foo', 'bar', '', 'baz', 'quux'] }

    result = s2.split(string, ':')
    assert { result == ['foo', 'bar', '', 'baz', 'quux'] }

    result = s3.split(string, ':')
    assert { result == %w[foo bar baz quux] }

    result = s1.rsplit(string, ':')
    assert { result == ['foo', 'bar', '', 'baz', 'quux'] }

    result = s2.rsplit(string, ':')
    assert { result == ['foo', 'bar', '', 'baz', 'quux'] }

    result = s3.rsplit(string, ':')
    assert { result == %w[foo bar baz quux] }
  end

  it 'removes all empty fields' do
    string = ':foo:bar::baz:quux:'

    result = s1.split(string, ':')
    assert { result == ['', 'foo', 'bar', '', 'baz', 'quux', ''] }

    result = s2.split(string, ':')
    assert { result == ['', 'foo', 'bar', '', 'baz', 'quux', ''] }

    result = s3.split(string, ':')
    assert { result == %w[foo bar baz quux] }

    result = s1.rsplit(string, ':')
    assert { result == ['', 'foo', 'bar', '', 'baz', 'quux', ''] }

    result = s2.rsplit(string, ':')
    assert { result == ['', 'foo', 'bar', '', 'baz', 'quux', ''] }

    result = s3.rsplit(string, ':')
    assert { result == %w[foo bar baz quux] }
  end

  test 'multiple separators + no field: removes everything' do
    string = '::::'

    result = s1.split(string, ':')
    assert { result == ['', '', '', '', ''] }

    result = s2.split(string, ':')
    assert { result == ['', '', '', '', ''] }

    result = s3.split(string, ':')
    assert { result == [] }

    result = s1.rsplit(string, ':')
    assert { result == ['', '', '', '', ''] }

    result = s2.rsplit(string, ':')
    assert { result == ['', '', '', '', ''] }

    result = s3.rsplit(string, ':')
    assert { result == [] }
  end

  test 'multiple separators + field: removes everything but the field' do
    string = ':::foo:::'

    result = s1.split(string, ':')
    assert { result == ['', '', '', 'foo', '', '', ''] }

    result = s2.split(string, ':')
    assert { result == ['', '', '', 'foo', '', '', ''] }

    result = s3.split(string, ':')
    assert { result == ['foo'] }

    result = s1.rsplit(string, ':')
    assert { result == ['', '', '', 'foo', '', '', ''] }

    result = s2.rsplit(string, ':')
    assert { result == ['', '', '', 'foo', '', '', ''] }

    result = s3.rsplit(string, ':')
    assert { result == ['foo'] }
  end
end
