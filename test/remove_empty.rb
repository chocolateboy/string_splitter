# frozen_string_literal: true

require_relative 'test_helper'

# confirm that the :remove_empty option removes empty fields

describe 'remove_empty' do
  s1 = StringSplitter.new # default: remove_empty: false
  s2 = StringSplitter.new(remove_empty: false)
  ss = StringSplitter.new(remove_empty: true)

  it 'removes leading empty tokens' do
    string = ':foo:bar:baz:quux'

    result = s1.split(string, ':')
    assert { result == ['', 'foo', 'bar', 'baz', 'quux'] }

    result = s2.split(string, ':')
    assert { result == ['', 'foo', 'bar', 'baz', 'quux'] }

    result = ss.split(string, ':') { true }
    assert { result == %w[foo bar baz quux] }
  end

  it 'removes trailing empty tokens' do
    string = 'foo:bar:baz:quux:'

    result = s1.split(string, ':') { true }
    assert { result == ['foo', 'bar', 'baz', 'quux', ''] }

    result = s2.split(string, ':') { true }
    assert { result == ['foo', 'bar', 'baz', 'quux', ''] }

    result = ss.split(string, ':') { true }
    assert { result == %w[foo bar baz quux] }
  end

  it 'removes embedded empty tokens' do
    string = 'foo:bar::baz:quux'

    result = s1.split(string, ':')
    assert { result == ['foo', 'bar', '', 'baz', 'quux'] }

    result = s2.split(string, ':')
    assert { result == ['foo', 'bar', '', 'baz', 'quux'] }

    result = ss.split(string, ':')
    assert { result == %w[foo bar baz quux] }
  end

  it 'removes all empty tokens' do
    string = ':foo:bar::baz:quux:'

    result = s1.split(string, ':')
    assert { result == ['', 'foo', 'bar', '', 'baz', 'quux', ''] }

    result = s2.split(string, ':')
    assert { result == ['', 'foo', 'bar', '', 'baz', 'quux', ''] }

    result = ss.split(string, ':')
    assert { result == %w[foo bar baz quux] }
  end

  test 'multiple separators + no field: removes everything' do
    string = '::::'

    result = s1.split(string, ':')
    assert { result == ['', '', '', '', ''] }

    result = s2.split(string, ':')
    assert { result == ['', '', '', '', ''] }

    result = ss.split(string, ':')
    assert { result == [] }
  end

  test 'multiple separators + field: removes everything but the field' do
    string = ':::foo:::'

    result = s1.split(string, ':')
    assert { result == ['', '', '', 'foo', '', '', ''] }

    result = s2.split(string, ':')
    assert { result == ['', '', '', 'foo', '', '', ''] }

    result = ss.split(string, ':')
    assert { result == ['foo'] }
  end
end
