# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.count contains the number of splits

describe 'split.count' do
  ss = StringSplitter.new

  test 'count: 0' do
    result = []
    ss.split('foo', ':') { |split| result << split.count; true }
    assert { result == [] }

    result = []
    ss.rsplit('foo', ':') { |split| result << split.count; true }
    assert { result == [] }
  end

  test 'count: 1' do
    result = []
    ss.split('foo:bar', ':') { |split| result << split.count; true }
    assert { result == [1] }

    result = []
    ss.rsplit('foo:bar', ':') { |split| result << split.count; true }
    assert { result == [1] }
  end

  test 'count: 2' do
    result = []
    ss.split('foo:bar:baz', ':') { |split| result << split.count; true }
    assert { result == [2, 2] }

    result = []
    ss.rsplit('foo:bar:baz', ':') { |split| result << split.count; true }
    assert { result == [2, 2] }
  end

  test 'count: 3' do
    result = []
    ss.split('foo:bar:baz:quux', ':') { |split| result << split.count; true }
    assert { result == [3, 3, 3] }

    result = []
    ss.rsplit('foo:bar:baz:quux', ':') { |split| result << split.count; true }
    assert { result == [3, 3, 3] }
  end
end
