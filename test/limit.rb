# frozen_string_literal: true

require_relative 'test_helper'

# confirm that String#split's limit parameter can be emulated

describe 'emulate limit' do
  string = 'foo:bar:baz:quux'
  s1 = StringSplitter.new # default: remove_empty: false
  s2 = StringSplitter.new(remove_empty: false)

  test 'limit: 1' do
    result = s1.split(string, ':') { false }
    assert { result == ['foo:bar:baz:quux'] }

    result = s2.split(string, ':') { false }
    assert { result == ['foo:bar:baz:quux'] }
  end

  test 'limit: 2' do
    result = s1.split(string, ':') { |split| split.pos == 1 }
    assert { result == ['foo', 'bar:baz:quux'] }

    result = s2.split(string, ':') { |split| split.pos == 1 }
    assert { result == ['foo', 'bar:baz:quux'] }
  end

  test 'limit: 3' do
    result = s1.split(string, ':') { |split| split.pos < 3 }
    assert { result == ['foo', 'bar', 'baz:quux'] }

    result = s2.split(string, ':') { |split| split.pos < 3 }
    assert { result == ['foo', 'bar', 'baz:quux'] }
  end

  test 'limit: 0' do
    result = s1.split(string, ':') { true }
    assert { result == ['foo', 'bar', 'baz', 'quux'] }

    result = s2.split(string, ':') { true }
    assert { result == ['foo', 'bar', 'baz', 'quux'] }
  end
end
