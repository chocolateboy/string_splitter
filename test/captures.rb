# frozen_string_literal: true

require_relative 'test_helper'

# test the include_captures and spread_captures options

def test_spread(ss)
  # no captures if the delimiter is a string
  result = ss.split('foo:bar:baz', ':')
  assert { result == %w[foo bar baz] }

  result = ss.rsplit('foo:bar:baz', ':')
  assert { result == %w[foo bar baz] }

  # no captures if the delimiter is a regex which doesn't contain captures
  result = ss.split('foo:bar:baz', /:/)
  assert { result == %w[foo bar baz] }

  result = ss.rsplit('foo:bar:baz', /:/)
  assert { result == %w[foo bar baz] }

  # one capture
  result = ss.split('foo:bar:baz', /(:)/)
  assert { result == ['foo', ':', 'bar', ':', 'baz'] }

  result = ss.rsplit('foo:bar:baz', /(:)/)
  assert { result == ['foo', ':', 'bar', ':', 'baz'] }

  # multiple captures
  result = ss.split('foo::bar::baz', /((:)(:))/)
  assert { result == ['foo', '::', ':', ':', 'bar', '::', ':', ':', 'baz'] }

  result = ss.rsplit('foo::bar::baz', /((:)(:))/)
  assert { result == ['foo', '::', ':', ':', 'bar', '::', ':', ':', 'baz'] }

  # optional captures
  result = ss.split('foo:bar:baz', /((-)|(:))/)
  assert { result == ['foo', ':', nil, ':', 'bar', ':', nil, ':', 'baz'] }

  result = ss.rsplit('foo:bar:baz', /((-)|(:))/)
  assert { result == ['foo', ':', nil, ':', 'bar', ':', nil, ':', 'baz'] }
end

describe 'spread_captures' do
  test 'spread' do
    s1 = StringSplitter.new
    s2 = StringSplitter.new(include_captures: true, spread_captures: true) # default options

    test_spread(s1)
    test_spread(s2)
  end

  test 'embed' do
    ss = StringSplitter.new(include_captures: true, spread_captures: false)

    # no capture arrays if the delimiter is a string
    result = ss.split('foo:bar:baz', ':')
    assert { result == %w[foo bar baz] }

    result = ss.rsplit('foo:bar:baz', ':')
    assert { result == %w[foo bar baz] }

    # no capture arrays if the delimiter is a regex which doesn't contain captures
    result = ss.split('foo:bar:baz', /:/)
    assert { result == %w[foo bar baz] }

    result = ss.rsplit('foo:bar:baz', /:/)
    assert { result == %w[foo bar baz] }

    # one capture
    result = ss.split('foo:bar:baz', /(:)/)
    assert { result == ['foo', [':'], 'bar', [':'], 'baz'] }

    result = ss.rsplit('foo:bar:baz', /(:)/)
    assert { result == ['foo', [':'], 'bar', [':'], 'baz'] }

    # multiple captures
    result = ss.split('foo::bar::baz', /((:)(:))/)
    assert { result == ['foo', ['::', ':', ':'], 'bar', ['::', ':', ':'], 'baz'] }

    result = ss.rsplit('foo::bar::baz', /((:)(:))/)
    assert { result == ['foo', ['::', ':', ':'], 'bar', ['::', ':', ':'], 'baz'] }

    # optional captures
    result = ss.split('foo:bar:baz', /((-)|(:))/)
    assert { result == ['foo', [':', nil, ':'], 'bar', [':', nil, ':'], 'baz'] }

    result = ss.rsplit('foo:bar:baz', /((-)|(:))/)
    assert { result == ['foo', [':', nil, ':'], 'bar', [':', nil, ':'], 'baz'] }
  end
end
