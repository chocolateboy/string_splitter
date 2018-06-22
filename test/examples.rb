# frozen_string_literal: true

require_relative 'test_helper'

# ensure the examples in the README work

describe 'examples' do
  s = StringSplitter.new

  specify 'same as String#split' do
    str = 'foo bar baz quux'
    want = ['foo', 'bar', 'baz', 'quux']

    assert { s.split(str) == want }
    assert { s.split(str, ' ') == want }
    assert { s.split(str, /\s+/) == want }
  end

  specify 'split on the first separator' do
    result = s.split('foo:bar:baz:quux', ':', at: 1)
    assert { result == ['foo', 'bar:baz:quux'] }
  end

  specify 'split on the last separator' do
    result = s.split('foo:bar:baz:quux', ':', at: -1)
    assert { result == ['foo:bar:baz', 'quux'] }
  end

  specify 'split on multiple separator indices' do
    result = s.split('1:2:3:4:5:6:7:8:9', ':', at: [1..3, -1])
    assert { result == ['1', '2', '3', '4:5:6:7:8', '9'] }
  end

  specify 'split from the right' do
    result = s.rsplit('1:2:3:4:5:6:7:8:9', ':', at: [1..3, 5])
    assert { result == ['1:2:3:4', '5:6', '7', '8', '9'] }
  end

  specify 'full control via a block' do
    result = s.split('a:a:a:b:c:c:e:a:a:d:c', ':') do |split|
      split.index > 1 && split.lhs == split.rhs
    end

    assert { result == ['a:a', 'a:b:c', 'c:e:a', 'a:d:c'] }
  end

  specify 'implement the `at` option manually' do
    result = s.split('foo:bar:baz', ':') { |split| split.index == 1 }
    assert { result == ['foo', 'bar:baz'] }

    result = s.split('foo:bar:baz', ':') { |split| split.index == split.count }
    assert { result == ['foo:bar', 'baz'] }
  end

  specify 'semi-structured input' do
    line = '-rw-r--r-- 1 user users   87 Jun 18 18:16 CHANGELOG.md'
    want = ['-rw-r--r--', '1', 'user', 'users', '87', 'Jun 18 18:16', 'CHANGELOG.md']

    result = s.split(line) do |split|
      case split.index when 1..5, 8 then true end
    end

    assert { result == want }
    assert { s.split(line, at: [1..5, 8]) == want }
  end
end
