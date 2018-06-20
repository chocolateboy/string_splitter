# frozen_string_literal: true

require_relative 'test_helper.rb'

STRING = 'foo:bar:baz:quux'

describe 'split' do
  s = StringSplitter.new # remove_empty: false

  describe 'limit' do
    specify 'limit: 1' do
      result = s.split(STRING, ':') { false }
      assert { result == ['foo:bar:baz:quux'] }
    end

    specify 'limit: 2' do
      result = s.split(STRING, ':') { |i| i == 1 }
      assert { result == ['foo', 'bar:baz:quux'] }
    end

    specify 'limit: 3' do
      result = s.split(STRING, ':') { |i| i < 3 }
      assert { result == ['foo', 'bar', 'baz:quux'] }
    end

    specify 'limit: 0' do
      result = s.split(STRING, ':') { true }
      assert { result == ['foo', 'bar', 'baz', 'quux'] }
    end
  end

  describe 'indices' do
    specify 'at: 2' do
      result = s.split(STRING, ':', at: 2)
      assert { result == ['foo:bar', 'baz:quux'] }
    end

    specify 'at: [1, 3]' do
      result = s.split(STRING, ':', at: [1, 3])
      assert { result == ['foo', 'bar:baz', 'quux'] }
    end
  end

  describe 'remove_empty' do
    ss = StringSplitter.new(remove_empty: true)

    it 'removes leading empty tokens' do
      string = ':foo:bar:baz:quux'

      result = s.split(string, ':')
      assert { result == ['', 'foo', 'bar', 'baz', 'quux'] }

      result = ss.split(string, ':') { true }
      assert { result == ['foo', 'bar', 'baz', 'quux'] }
    end

    it 'removes trailing empty tokens' do
      string = 'foo:bar:baz:quux:'

      result = s.split(string, ':') { true }
      assert { result == ['foo', 'bar', 'baz', 'quux', ''] }

      result = ss.split(string, ':') { true }
      assert { result == ['foo', 'bar', 'baz', 'quux'] }
    end

    it 'removes trailing embedded empty tokens' do
      string = 'foo:bar::baz:quux'

      result = s.split(string, ':')
      assert { result == ['foo', 'bar', '', 'baz', 'quux'] }

      result = ss.split(string, ':')
      assert { result == ['foo', 'bar', 'baz', 'quux'] }
    end

    it 'removes all empty tokens' do
      string = ':foo:bar::baz:quux:'

      result = s.split(string, ':')
      assert { result == ['', 'foo', 'bar', '', 'baz', 'quux', ''] }

      result = ss.split(string, ':')
      assert { result == ['foo', 'bar', 'baz', 'quux'] }
    end
  end
end
