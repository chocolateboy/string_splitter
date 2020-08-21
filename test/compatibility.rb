# frozen_string_literal: true

require_relative 'test_helper'

# verify the incompatibilities documented in the "Incompatibilities with
# String#split" section

describe 'String#split incompatibilities' do
  test 'no auto-trim' do
    ss = StringSplitter.new

    assert { ' foo bar baz '.split == %w[foo bar baz] }
    assert { ' foo bar baz '.split(' ') == %w[foo bar baz] }

    assert { ss.split(' foo bar baz ') == ['', 'foo', 'bar', 'baz', ''] }
    assert { ss.split(' foo bar baz ', ' ') == ['', 'foo', 'bar', 'baz', ''] }

    assert { ss.rsplit(' foo bar baz ') == ['', 'foo', 'bar', 'baz', ''] }
    assert { ss.rsplit(' foo bar baz ', ' ') == ['', 'foo', 'bar', 'baz', ''] }
  end

  test 'preserve optional captures' do
    s1 = StringSplitter.new(spread_captures: true)
    s2 = StringSplitter.new(spread_captures: false)
    s3 = StringSplitter.new(spread_captures: :compact)

    assert { 'foo:bar:baz'.scan(/(:)|(-)/)  == [[':', nil], [':', nil]] }
    assert { 'foo:bar:baz'.split(/(:)|(-)/) == %w[foo : bar : baz] }

    assert { s1.split('foo:bar:baz', /(:)|(-)/) == ['foo', ':', nil, 'bar', ':', nil, 'baz'] }
    assert { s2.split('foo:bar:baz', /(:)|(-)/) == ['foo', [':', nil], 'bar', [':', nil], 'baz'] }
    assert { s3.split('foo:bar:baz', /(:)|(-)/) == %w[foo : bar : baz] }

    assert { s1.rsplit('foo:bar:baz', /(:)|(-)/) == ['foo', ':', nil, 'bar', ':', nil, 'baz'] }
    assert { s2.rsplit('foo:bar:baz', /(:)|(-)/) == ['foo', [':', nil], 'bar', [':', nil], 'baz'] }
    assert { s3.rsplit('foo:bar:baz', /(:)|(-)/) == %w[foo : bar : baz] }
  end
end
