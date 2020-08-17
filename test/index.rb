# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.index is 0-based

describe 'split.index' do
  ss = StringSplitter.new

  it 'is 0-based for a split at the beginning' do
    result = ss.split('foo:bar:baz:quux', ':') do |split|
      split.index.zero?
    end

    assert { result == ['foo', 'bar:baz:quux'] }

    result = ss.rsplit('foo:bar:baz:quux', ':') do |split|
      split.index.zero?
    end

    assert { result == %w[foo:bar:baz quux] }
  end

  it 'is 0-based for a split at the end' do
    result = ss.split('foo:bar:baz:quux', ':') do |split|
      split.index == 2
    end

    assert { result == ['foo:bar:baz', 'quux'] }

    result = ss.rsplit('foo:bar:baz:quux', ':') do |split|
      split.index == 2
    end

    assert { result == %w[foo bar:baz:quux] }
  end

  it 'is 0-based for a split in the middle' do
    result = ss.split('foo:bar:baz:quux', ':') do |split|
      split.index == 1
    end

    assert { result == ['foo:bar', 'baz:quux'] }

    result = ss.rsplit('foo:bar:baz:quux', ':') do |split|
      split.index == 1
    end

    assert { result == %w[foo:bar baz:quux] }
  end

  it 'is 0-based for multiple split indices' do
    result = ss.split('foo:bar:baz:quux', ':') do |split|
      [0, 2].include?(split.index)
    end

    assert { result == %w[foo bar:baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', ':') do |split|
      [0, 2].include?(split.index)
    end

    assert { result == %w[foo bar:baz quux] }
  end
end
