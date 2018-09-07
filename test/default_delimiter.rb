# frozen_string_literal: true

require_relative 'test_helper'

def assert_common(s)
  # it replaces the default whitespace delimiter
  result = s.split('1 2 3 4')
  assert { result != %w[1 2 3 4] }

  result = s.rsplit('1 2 3 4')
  assert { result != %w[1 2 3 4] }

  # it can be overridden with a per-method string
  result = s.split('1 2 3 4', ' ')
  assert { result == %w[1 2 3 4] }

  result = s.rsplit('1 2 3 4', ' ')
  assert { result == %w[1 2 3 4] }

  # it can be overridden with a per-method regex
  result = s.split('1-2:3-4', /[:-]/)
  assert { result == %w[1 2 3 4] }

  result = s.rsplit('1-2:3-4', /[:-]/)
  assert { result == %w[1 2 3 4] }
end

describe 'default_delimiter' do
  test 'string' do
    s = StringSplitter.new(default_delimiter: ':')

    assert_common(s)

    result = s.split('foo:bar:baz:quux')
    assert { result == %w[foo bar baz quux] }

    result = s.rsplit('foo:bar:baz:quux')
    assert { result == %w[foo bar baz quux] }
  end

  test 'empty string' do
    s = StringSplitter.new(default_delimiter: '')

    assert_common(s)

    result = s.split('foobar')
    assert { result == %w[f o o b a r] }

    result = s.rsplit('foobar')
    assert { result == %w[f o o b a r] }
  end

  test 'regex without captures' do
    s = StringSplitter.new(default_delimiter: /[:-]/)

    assert_common(s)

    result = s.split('foo:bar-baz:quux')
    assert { result == %w[foo bar baz quux] }

    result = s.rsplit('foo:bar-baz:quux')
    assert { result == %w[foo bar baz quux] }
  end

  test 'regex with captures' do
    s = StringSplitter.new(default_delimiter: /(X)(Y)/, include_captures: false)
    ss = StringSplitter.new(default_delimiter: /(X)(Y)/, include_captures: true)

    assert_common(s)
    assert_common(ss)

    result = s.split('fooXYbarXYbazXYquux')
    assert { result == %w[foo bar baz quux] }

    result = s.rsplit('fooXYbarXYbazXYquux')
    assert { result == %w[foo bar baz quux] }

    result = ss.split('fooXYbarXYbazXYquux')
    assert { result == %w[foo X Y bar X Y baz X Y quux] }

    result = ss.rsplit('fooXYbarXYbazXYquux')
    assert { result == %w[foo X Y bar X Y baz X Y quux] }
  end
end
