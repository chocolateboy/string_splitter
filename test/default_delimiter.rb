# frozen_string_literal: true

require_relative 'test_helper.rb'

def assert_common(s)
  # it replaces the default whitespace delimiter
  result = s.split('1 2 3 4')
  assert { result != ['1', '2', '3', '4'] }

  # it can be overridden with a per-method string
  result = s.split('1 2 3 4', ' ')
  assert { result == ['1', '2', '3', '4'] }

  # it can be overridden with a per-method regex
  result = s.split('1-2:3-4', /[:-]/)
  assert { result == ['1', '2', '3', '4'] }
end

describe 'default_delimiter' do
  specify 'string' do
    s = StringSplitter.new(default_delimiter: ':')

    result = s.split('foo:bar:baz:quux')
    assert { result == ['foo', 'bar', 'baz', 'quux'] }

    result = s.rsplit('foo:bar:baz:quux')
    assert { result == ['foo', 'bar', 'baz', 'quux'] }

    assert_common(s)
  end

  specify 'empty string' do
    s = StringSplitter.new(default_delimiter: '')

    result = s.split('foobar')
    assert { result == ['f', 'o', 'o', 'b', 'a', 'r'] }
  end

  specify 'regex without captures' do
    s = StringSplitter.new(default_delimiter: /[:-]/)

    result = s.split('foo:bar-baz:quux')
    assert { result == ['foo', 'bar', 'baz', 'quux'] }

    result = s.rsplit('foo:bar-baz:quux')
    assert { result == ['foo', 'bar', 'baz', 'quux'] }

    assert_common(s)
  end

  specify 'regex with captures' do
    s = StringSplitter.new(default_delimiter: /(X)(Y)/, include_captures: false)
    ss = StringSplitter.new(default_delimiter: /(X)(Y)/, include_captures: true)

    result = s.split('fooXYbarXYbazXYquux')
    assert { result == ['foo', 'bar', 'baz', 'quux'] }

    result = s.rsplit('fooXYbarXYbazXYquux')
    assert { result == ['foo', 'bar', 'baz', 'quux'] }

    result = ss.split('fooXYbarXYbazXYquux')
    assert { result == ['foo', 'X', 'Y', 'bar', 'X', 'Y', 'baz', 'X', 'Y', 'quux'] }

    result = ss.rsplit('fooXYbarXYbazXYquux')
    assert { result == ['foo', 'X', 'Y', 'bar', 'X', 'Y', 'baz', 'X', 'Y', 'quux'] }

    assert_common(s)
  end
end
