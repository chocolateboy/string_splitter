# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.lhs contains the field before the split

describe 'split.lhs' do
  ss = StringSplitter.new

  test '0 splits' do
    result = []
    ss.split('foo', ':') { |split| result << split.lhs; true }
    assert { result == [] }

    result = []
    ss.rsplit('foo', ':') { |split| result << split.lhs; true }
    assert { result == [] }
  end

  test '1 split' do
    result = []
    ss.split('foo:bar', ':') { |split| result << split.lhs; true }
    assert { result == %w[foo] }

    result = []
    ss.rsplit('foo:bar', ':') { |split| result << split.lhs; true }
    assert { result == %w[foo] }
  end

  test '2 splits' do
    result = []
    ss.split('foo:bar:baz', ':') { |split| result << split.lhs; true }
    assert { result == %w[foo bar] }

    result = []
    ss.rsplit('foo:bar:baz', ':') { |split| result << split.lhs; true }
    assert { result == %w[bar foo] }
  end

  test '3 splits' do
    result = []
    ss.split('foo:bar:baz:quux', ':') { |split| result << split.lhs; true }
    assert { result == %w[foo bar baz] }

    result = []
    ss.rsplit('foo:bar:baz:quux', ':') { |split| result << split.lhs; true }
    assert { result == %w[baz bar foo] }
  end

  test 'empty lhs, 1 split' do
    result = []
    ss.split(':foo', ':') { |split| result << split.lhs; true }
    assert { result == [''] }

    result = []
    ss.rsplit(':foo', ':') { |split| result << split.lhs; true }
    assert { result == [''] }
  end

  test 'empty lhs, multiple splits' do
    result = []
    ss.split(':foo:bar:baz:quux', ':') { |split| result << split.lhs; true }
    assert { result == ['', 'foo', 'bar', 'baz'] }

    result = []
    ss.rsplit(':foo:bar:baz:quux', ':') { |split| result << split.lhs; true }
    assert { result == ['baz', 'bar', 'foo', ''] }
  end
end
