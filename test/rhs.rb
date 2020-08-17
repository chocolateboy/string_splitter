# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.rhs contains the field after the split

describe 'split.rhs' do
  ss = StringSplitter.new

  test 'rhs: 1' do
    result = []
    ss.split('foo:bar', ':') { |split| result << split.rhs; true }
    assert { result == %w[bar] }

    result = []
    ss.rsplit('foo:bar', ':') { |split| result << split.rhs; true }
    assert { result == %w[bar] }
  end

  test 'rhs: 2' do
    result = []
    ss.split('foo:bar:baz', ':') { |split| result << split.rhs; true }
    assert { result == %w[bar baz] }

    result = []
    ss.rsplit('foo:bar:baz', ':') { |split| result << split.rhs; true }
    assert { result == %w[baz bar] }
  end

  test 'rhs: 3' do
    result = []
    ss.split('foo:bar:baz:quux', ':') { |split| result << split.rhs; true }
    assert { result == %w[bar baz quux] }

    result = []
    ss.rsplit('foo:bar:baz:quux', ':') { |split| result << split.rhs; true }
    assert { result == %w[quux baz bar] }
  end

  test 'rhs: 0' do
    result = []
    ss.split('foo', ':') { |split| result << split.rhs; true }
    assert { result == [] }

    result = []
    ss.rsplit('foo', ':') { |split| result << split.rhs; true }
    assert { result == [] }
  end

  test 'empty: single' do
    result = []
    ss.split('foo:', ':') { |split| result << split.rhs; true }
    assert { result == [''] }

    result = []
    ss.rsplit('foo:', ':') { |split| result << split.rhs; true }
    assert { result == [''] }
  end

  test 'empty: multi' do
    result = []
    ss.split('foo:bar:baz:quux:', ':') { |split| result << split.rhs; true }
    assert { result == ['bar', 'baz', 'quux', ''] }

    result = []
    ss.rsplit('foo:bar:baz:quux:', ':') { |split| result << split.rhs; true }
    assert { result == ['', 'quux', 'baz', 'bar'] }
  end
end
