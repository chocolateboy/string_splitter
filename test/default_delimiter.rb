# frozen_string_literal: true

require_relative 'test_helper'

def assert_common(ss)
  # it replaces the default whitespace delimiter
  result = ss.split('1 2 3 4')
  assert { result != %w[1 2 3 4] }

  result = ss.rsplit('1 2 3 4')
  assert { result != %w[1 2 3 4] }

  # it can be overridden with a per-method string
  result = ss.split('1 2 3 4', ' ')
  assert { result == %w[1 2 3 4] }

  result = ss.rsplit('1 2 3 4', ' ')
  assert { result == %w[1 2 3 4] }

  # it can be overridden with a per-method regex
  result = ss.split('1-2:3-4', /[:-]/)
  assert { result == %w[1 2 3 4] }

  result = ss.rsplit('1-2:3-4', /[:-]/)
  assert { result == %w[1 2 3 4] }
end

describe 'default_delimiter' do
  test 'empty string' do
    ss = StringSplitter.new(default_delimiter: '')

    assert_common(ss)

    result = ss.split('foobar')
    assert { result == %w[f o o b a r] }

    result = ss.rsplit('foobar')
    assert { result == %w[f o o b a r] }
  end

  test 'empty regex' do
    ss = StringSplitter.new(default_delimiter: //)

    assert_common(ss)

    result = ss.split('foobar')
    assert { result == %w[f o o b a r] }

    result = ss.rsplit('foobar')
    assert { result == %w[f o o b a r] }
  end

  test 'non-empty string' do
    ss = StringSplitter.new(default_delimiter: ':')

    assert_common(ss)

    result = ss.split('foo:bar:baz:quux')
    assert { result == %w[foo bar baz quux] }

    result = ss.rsplit('foo:bar:baz:quux')
    assert { result == %w[foo bar baz quux] }
  end

  test 'regex without captures (1)' do
    ss = StringSplitter.new(default_delimiter: /[:-]/)

    assert_common(ss)

    result = ss.split('foo:bar-baz:quux')
    assert { result == %w[foo bar baz quux] }

    result = ss.rsplit('foo:bar-baz:quux')
    assert { result == %w[foo bar baz quux] }
  end

  test 'regex without captures (2)' do
    ss = StringSplitter.new(default_delimiter: /(?::|-)/)

    assert_common(ss)

    result = ss.split('foo:bar-baz:quux')
    assert { result == %w[foo bar baz quux] }

    result = ss.rsplit('foo:bar-baz:quux')
    assert { result == %w[foo bar baz quux] }
  end

  test 'regex with captures' do
    s1 = StringSplitter.new(default_delimiter: /(X)(Y)/, include_captures: false)
    s2 = StringSplitter.new(default_delimiter: /(X)(Y)/, include_captures: true)

    assert_common(s1)
    assert_common(s2)

    result = s1.split('fooXYbarXYbazXYquux')
    assert { result == %w[foo bar baz quux] }

    result = s1.rsplit('fooXYbarXYbazXYquux')
    assert { result == %w[foo bar baz quux] }

    result = s2.split('fooXYbarXYbazXYquux')
    assert { result == %w[foo X Y bar X Y baz X Y quux] }

    result = s2.rsplit('fooXYbarXYbazXYquux')
    assert { result == %w[foo X Y bar X Y baz X Y quux] }
  end
end
