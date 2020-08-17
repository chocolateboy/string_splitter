# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.position and its split.pos alias is 1-based

describe 'split.position' do
  ss = StringSplitter.new

  it 'is 1-based for a split at the beginning' do
    result = ss.split('foo:bar:baz:quux', ':') { |split| split.position == 1 }
    assert { result == %w[foo bar:baz:quux] }

    result = ss.split('foo:bar:baz:quux', ':') { |split| split.pos == 1 }
    assert { result == %w[foo bar:baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', ':') { |split| split.position == 1 }
    assert { result == %w[foo:bar:baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', ':') { |split| split.pos == 1 }
    assert { result == %w[foo:bar:baz quux] }
  end

  it 'is 1-based for a split at the end' do
    result = ss.split('foo:bar:baz:quux', ':') { |split| split.position == 3 }
    assert { result == %w[foo:bar:baz quux] }

    result = ss.split('foo:bar:baz:quux', ':') { |split| split.pos == 3 }
    assert { result == %w[foo:bar:baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', ':') { |split| split.position == 3 }
    assert { result == %w[foo bar:baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', ':') { |split| split.pos == 3 }
    assert { result == %w[foo bar:baz:quux] }
  end

  it 'is 1-based for a split in the middle' do
    result = ss.split('foo:bar:baz:quux', ':') { |split| split.position == 2 }
    assert { result == %w[foo:bar baz:quux] }

    result = ss.split('foo:bar:baz:quux', ':') { |split| split.pos == 2 }
    assert { result == %w[foo:bar baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', ':') { |split| split.position == 2 }
    assert { result == %w[foo:bar baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', ':') { |split| split.pos == 2 }
    assert { result == %w[foo:bar baz:quux] }
  end

  it 'is 1-based for multiple split positions' do
    result = ss.split('foo:bar:baz:quux', ':') do |split|
      [1, 3].include?(split.position)
    end

    assert { result == %w[foo bar:baz quux] }

    result = ss.split('foo:bar:baz:quux', ':') do |split|
      [1, 3].include?(split.pos)
    end

    assert { result == %w[foo bar:baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', ':') do |split|
      [1, 3].include?(split.position)
    end

    assert { result == %w[foo bar:baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', ':') do |split|
      [1, 3].include?(split.pos)
    end

    assert { result == %w[foo bar:baz quux] }
  end
end
