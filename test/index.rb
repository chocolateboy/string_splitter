# frozen_string_literal: true

# confirm split.index and its split.offset alias is 0-based

require_relative 'test_helper'

describe 'index' do
  s = StringSplitter.new

  %i[index offset].each do |name|
    type = name == :index ? :name : :alias

    describe "#{type}: #{name}" do
      it 'is 0-based for a split at the beginning' do
        result = s.split('foo:bar:baz:quux', ':') do |split|
          split.send(name) == 0
        end

        assert { result == ['foo', 'bar:baz:quux'] }
      end

      it 'is 0-based for a split at the end' do
        result = s.split('foo:bar:baz:quux', ':') do |split|
          split.send(name) == 2
        end

        assert { result == ['foo:bar:baz', 'quux'] }
      end

      it 'is 0-based for a split in the middle' do
        result = s.split('foo:bar:baz:quux', ':') do |split|
          split.send(name) == 1
        end

        assert { result == ['foo:bar', 'baz:quux'] }
      end

      it 'is 0-based for multiple split indices' do
        result = s.split('foo:bar:baz:quux', ':') do |split|
          [0, 2].include?(split.send(name))
        end

        assert { result == ['foo', 'bar:baz', 'quux'] }
      end
    end
  end
end
