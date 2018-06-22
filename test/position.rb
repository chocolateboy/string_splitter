# frozen_string_literal: true

# confirm split.position and its split.pos alias is 1-based

require_relative 'test_helper'

describe 'ordinal' do
  s = StringSplitter.new

  %i[position pos].each do |name|
    type = name == :position ? :name : :alias

    describe "#{type}: #{name}" do
      it 'is 1-based for a split at the beginning' do
        result = s.split('foo:bar:baz:quux', ':') do |split|
          split.send(name) == 1
        end

        assert { result == ['foo', 'bar:baz:quux'] }
      end

      it 'is 1-based for a split at the end' do
        result = s.split('foo:bar:baz:quux', ':') do |split|
          split.send(name) == 3
        end

        assert { result == ['foo:bar:baz', 'quux'] }
      end

      it 'is 1-based for a split in the middle' do
        result = s.split('foo:bar:baz:quux', ':') do |split|
          split.send(name) == 2
        end

        assert { result == ['foo:bar', 'baz:quux'] }
      end

      it 'is 1-based for multiple split positions' do
        result = s.split('foo:bar:baz:quux', ':') do |split|
          [1, 3].include?(split.send(name))
        end

        assert { result == ['foo', 'bar:baz', 'quux'] }
      end
    end
  end
end
