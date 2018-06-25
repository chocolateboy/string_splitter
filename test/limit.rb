# frozen_string_literal: true

require_relative 'test_helper'

# confirm that String#split's limit parameter can be emulated

describe 'emulate limit' do
  string = 'foo:bar:baz:quux'
  s = StringSplitter.new

  test 'limit: 1' do
    result = s.split(string, ':') { false }
    assert { result == ['foo:bar:baz:quux'] }
  end

  test 'limit: 2' do
    result = s.split(string, ':') { |split| split.pos == 1 }
    assert { result == %w[foo bar:baz:quux] }
  end

  test 'limit: 3' do
    result = s.split(string, ':') { |split| split.pos < 3 }
    assert { result == %w[foo bar baz:quux] }
  end

  test 'limit: 0' do
    result = s.split(string, ':') { true }
    assert { result == %w[foo bar baz quux] }
  end
end
