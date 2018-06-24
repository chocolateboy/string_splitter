# frozen_string_literal: true

require_relative 'test_helper'

describe 'remove_empty' do
  s = StringSplitter.new # remove_empty: false
  ss = StringSplitter.new(remove_empty: true)

  it 'removes leading empty tokens' do
    string = ':foo:bar:baz:quux'

    result = s.split(string, ':')
    assert { result == ['', 'foo', 'bar', 'baz', 'quux'] }

    result = ss.split(string, ':') { true }
    assert { result == ['foo', 'bar', 'baz', 'quux'] }
  end

  it 'removes trailing empty tokens' do
    string = 'foo:bar:baz:quux:'

    result = s.split(string, ':') { true }
    assert { result == ['foo', 'bar', 'baz', 'quux', ''] }

    result = ss.split(string, ':') { true }
    assert { result == ['foo', 'bar', 'baz', 'quux'] }
  end

  it 'removes embedded empty tokens' do
    string = 'foo:bar::baz:quux'

    result = s.split(string, ':')
    assert { result == ['foo', 'bar', '', 'baz', 'quux'] }

    result = ss.split(string, ':')
    assert { result == ['foo', 'bar', 'baz', 'quux'] }
  end

  it 'removes all empty tokens' do
    string = ':foo:bar::baz:quux:'

    result = s.split(string, ':')
    assert { result == ['', 'foo', 'bar', '', 'baz', 'quux', ''] }

    result = ss.split(string, ':')
    assert { result == ['foo', 'bar', 'baz', 'quux'] }
  end

  test 'multiple separators + no field: removes everything' do
    string = '::::'

    result = s.split(string, ':')
    assert { result == ['', '', '', '', ''] }

    result = ss.split(string, ':')
    assert { result == [] }
  end

  test 'multiple separators + field: removes everything but the field' do
    string = ':::foo:::'

    result = s.split(string, ':')
    assert { result == ['', '', '', 'foo', '', '', ''] }

    result = ss.split(string, ':')
    assert { result == ['foo'] }
  end
end
