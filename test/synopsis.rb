# frozen_string_literal: true

require_relative 'test_helper'

LINE = '-rw-r--r-- 1 user users   87 Jun 18 18:16 CHANGELOG.md'
WANT = ['-rw-r--r--', '1', 'user', 'users', '87', 'Jun 18 18:16', 'CHANGELOG.md']

describe 'synopsis' do
  it 'allows `remove_empty` and `limit` to be combined' do
    s = StringSplitter.new(remove_empty: true)

    result = s.split('::foo:bar::baz:quux::', ':', at: 1)
    assert { result == ['foo', 'bar:baz:quux'] }

    result = s.split('::foo:bar::baz:quux::', ':') { |split| split.index == 1 }
    assert { result == ['foo', 'bar:baz:quux'] }
  end

  it 'splits the output of ls (1)' do
    s = StringSplitter.new

    got = s.split(LINE, at: [1..5, 8])
    assert { got == WANT }
  end
end
