# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.lhs contains the field before the split

describe 'split.lhs' do
  s = StringSplitter.new

  test 'lhs: 1' do
    result = []
    s.split('foo:bar', ':') { |split| result << split.lhs; true }
    assert { result == %w[foo] }
  end

  test 'lhs: 2' do
    result = []
    s.split('foo:bar:baz', ':') { |split| result << split.lhs; true }
    assert { result == %w[foo bar] }
  end

  test 'lhs: 3' do
    result = []
    s.split('foo:bar:baz:quux', ':') { |split| result << split.lhs; true }
    assert { result == %w[foo bar baz] }
  end

  test 'lhs: 0' do
    result = []
    s.split('foo', ':') { |split| result << split.lhs; true }
    assert { result == [] }
  end

  test 'empty: single' do
    result = []
    s.split(':foo', ':') { |split| result << split.lhs; true }
    assert { result == [''] }
  end

  test 'empty: multi' do
    result = []
    s.split(':foo:bar:baz:quux', ':') { |split| result << split.lhs; true }
    assert { result == ['', 'foo', 'bar', 'baz'] }
  end
end
