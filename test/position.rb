# frozen_string_literal: true

# confirm split.position and its split.pos alias is 1-based

require_relative 'test_helper'

describe 'split.position' do
  s = StringSplitter.new

  it 'is 1-based for a split at the beginning' do
    result = s.split('foo:bar:baz:quux', ':') { |split| split.position == 1 }
    assert { result == ['foo', 'bar:baz:quux'] }

    result = s.split('foo:bar:baz:quux', ':') { |split| split.pos == 1 }
    assert { result == ['foo', 'bar:baz:quux'] }
  end

  it 'is 1-based for a split at the end' do
    result = s.split('foo:bar:baz:quux', ':') { |split| split.position == 3 }
    assert { result == ['foo:bar:baz', 'quux'] }

    result = s.split('foo:bar:baz:quux', ':') { |split| split.pos == 3 }
    assert { result == ['foo:bar:baz', 'quux'] }
  end

  it 'is 1-based for a split in the middle' do
    result = s.split('foo:bar:baz:quux', ':') { |split| split.position == 2 }
    assert { result == ['foo:bar', 'baz:quux'] }

    result = s.split('foo:bar:baz:quux', ':') { |split| split.pos == 2 }
    assert { result == ['foo:bar', 'baz:quux'] }
  end

  it 'is 1-based for multiple split positions' do
    result = s.split('foo:bar:baz:quux', ':') do |split|
      [1, 3].include?(split.position)
    end

    assert { result == ['foo', 'bar:baz', 'quux'] }

    result = s.split('foo:bar:baz:quux', ':') do |split|
      [1, 3].include?(split.pos)
    end

    assert { result == ['foo', 'bar:baz', 'quux'] }
  end
end
