# frozen_string_literal: true

require_relative 'test_helper'

# ensure the examples in the README work

describe 'examples' do
  ss = StringSplitter.new

  test 'same as String#split (1)' do
    str = 'foo bar baz quux'
    want = %w[foo bar baz quux]

    assert { ss.split(str) == want }
    assert { ss.split(str, ' ') == want }
    assert { ss.split(str, /\s+/) == want }
  end

  test 'same as String#split (2)' do
    want = %w[f o o]

    assert { ss.split('foo', '') == want }
    assert { ss.split('foo', //) == want }
  end

  test 'same as String#split (3)' do
    want = []

    assert { ss.split('', ':') == want }
    assert { ss.split('', /:/) == want }
  end

  test 'split on the first separator' do
    result = ss.split('foo:bar:baz:quux', ':', at: 1)
    assert { result == ['foo', 'bar:baz:quux'] }
  end

  test 'split on the last separator' do
    result = ss.split('foo:bar:baz:quux', ':', at: -1)
    assert { result == ['foo:bar:baz', 'quux'] }
  end

  test 'split at multiple separator positions' do
    result = ss.split('1:2:3:4:5:6:7:8:9', ':', at: [1..3, -1])
    assert { result == ['1', '2', '3', '4:5:6:7:8', '9'] }
  end

  test 'split from the right' do
    result = ss.rsplit('1:2:3:4:5:6:7:8:9', ':', at: [1..3, 5])
    assert { result == ['1:2:3:4', '5:6', '7', '8', '9'] }
  end

  test 'full control via a block (1)' do
    result = ss.split('a:a:a:b:c:c:e:a:a:d:c', ':') do |split|
      split.index.positive? && split.lhs == split.rhs
    end

    assert { result == ['a:a', 'a:b:c', 'c:e:a', 'a:d:c'] }
  end

  test 'full control via a block (2)' do
    string = 'banana'.chars.sort.join # "aaabnn"

    result = ss.split(string, '') do |split|
      split.rhs != split.lhs
    end

    assert { result == %w[aaa b nn] }
  end

  test 'implement the `at` option manually' do
    result = ss.split('foo:bar:baz', ':') { |split| split.index.zero? }
    assert { result == ['foo', 'bar:baz'] }

    result = ss.split('foo:bar:baz', ':') { |split| split.position == split.count }
    assert { result == ['foo:bar', 'baz'] }
  end

  test 'semi-structured input' do
    line = '-rw-r--r-- 1 user users   87 Jun 18 18:16 CHANGELOG.md'
    want = ['-rw-r--r--', '1', 'user', 'users', '87', 'Jun 18 18:16', 'CHANGELOG.md']
    match = line.match(/^(\S+) \s+ (\d+) \s+ (\S+) \s+ (\S+) \s+ (\d+) \s+ (\S+ \s+ \d+ \s+ \S+) \s+ (.+)$/x)

    result = ss.split(line) do |split|
      case split.position when 1..5, 8 then true end
    end

    assert { match.captures == want }
    assert { result == want }
    assert { ss.split(line, at: [1..5, 8]) == want }
  end
end
