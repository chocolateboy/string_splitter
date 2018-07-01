# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.count contains the number of splits

describe 'split.count' do
  s = StringSplitter.new

  test 'count: 1' do
    result = []
    s.split('foo:bar', ':') { |split| result << split.count; true }
    assert { result == [1] }
  end

  test 'count: 2' do
    result = []
    s.split('foo:bar:baz', ':') { |split| result << split.count; true }
    assert { result == [2, 2] }
  end

  test 'count: 3' do
    result = []
    s.split('foo:bar:baz:quux', ':') { |split| result << split.count; true }
    assert { result == [3, 3, 3] }
  end

  test 'count: 0' do
    result = []
    s.split('foo', ':') { |split| result << split.count; true }
    assert { result == [] }
  end
end
