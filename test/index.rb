# frozen_string_literal: true

# confirm split.index is 0-based

require_relative 'test_helper'

describe 'split.index' do
  s = StringSplitter.new

  it 'is 0-based for a split at the beginning' do
    result = s.split('foo:bar:baz:quux', ':') do |split|
      split.index == 0
    end

    assert { result == ['foo', 'bar:baz:quux'] }
  end

  it 'is 0-based for a split at the end' do
    result = s.split('foo:bar:baz:quux', ':') do |split|
      split.index == 2
    end

    assert { result == ['foo:bar:baz', 'quux'] }
  end

  it 'is 0-based for a split in the middle' do
    result = s.split('foo:bar:baz:quux', ':') do |split|
      split.index == 1
    end

    assert { result == ['foo:bar', 'baz:quux'] }
  end

  it 'is 0-based for multiple split indices' do
    result = s.split('foo:bar:baz:quux', ':') do |split|
      [0, 2].include?(split.index)
    end

    assert { result == ['foo', 'bar:baz', 'quux'] }
  end
end
