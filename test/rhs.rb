# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.rhs contains the field after the split

describe 'split.rhs' do
  s = StringSplitter.new

  test 'rhs: 1' do
    result = []
    s.split('foo:bar', ':') { |split| result << split.rhs; true }
    assert { result == %w[bar] }
  end

  test 'rhs: 2' do
    result = []
    s.split('foo:bar:baz', ':') { |split| result << split.rhs; true }
    assert { result == %w[bar baz] }
  end

  test 'rhs: 3' do
    result = []
    s.split('foo:bar:baz:quux', ':') { |split| result << split.rhs; true }
    assert { result == %w[bar baz quux] }
  end

  test 'rhs: 0' do
    result = []
    s.split('foo', ':') { |split| result << split.rhs; true }
    assert { result == [] }
  end

  test 'empty: single' do
    result = []
    s.split('foo:', ':') { |split| result << split.rhs; true }
    assert { result == [''] }
  end

  test 'empty: multi' do
    result = []
    s.split('foo:bar:baz:quux:', ':') { |split| result << split.rhs; true }
    assert { result == ['bar', 'baz', 'quux', ''] }
  end
end
