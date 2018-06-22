# frozen_string_literal: true

require_relative 'test_helper.rb'

STRING = 'foo:bar:baz:quux'

describe 'split' do
  s = StringSplitter.new # remove_empty: false

  describe 'emulate limit' do
    specify 'limit: 1' do
      result = s.split(STRING, ':') { false }
      assert { result == ['foo:bar:baz:quux'] }
    end

    specify 'limit: 2' do
      result = s.split(STRING, ':') { |split| split.pos == 1 }
      assert { result == ['foo', 'bar:baz:quux'] }
    end

    specify 'limit: 3' do
      result = s.split(STRING, ':') { |split| split.pos < 3 }
      assert { result == ['foo', 'bar', 'baz:quux'] }
    end

    specify 'limit: 0' do
      result = s.split(STRING, ':') { true }
      assert { result == ['foo', 'bar', 'baz', 'quux'] }
    end
  end

  describe 'positions' do
    specify 'at: 2' do
      result = s.split(STRING, ':', at: 2)
      assert { result == ['foo:bar', 'baz:quux'] }
    end

    specify 'at: -1' do
      result = s.split(STRING, ':', at: -1)
      assert { result == ['foo:bar:baz', 'quux'] }
    end

    specify 'at: [1, -1]' do
      result = s.split(STRING, ':', at: [1, -1])
      assert { result == ['foo', 'bar:baz', 'quux'] }
    end
  end
end
