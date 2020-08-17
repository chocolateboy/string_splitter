# frozen_string_literal: true

require_relative 'test_helper'

# confirm that String#split's limit parameter can be emulated

string = 'foo:bar:baz:quux'
ss = StringSplitter.new

describe 'emulate limit' do
  test 'limit: 0' do
    result = ss.split(string, ':') { true }
    assert { result == %w[foo bar baz quux] }

    result = ss.rsplit(string, ':') { true }
    assert { result == %w[foo bar baz quux] }
  end

  test 'limit: 1' do
    result = ss.split(string, ':') { |split| split.pos < 1 }
    assert { result == ['foo:bar:baz:quux'] }

    result = ss.rsplit(string, ':') { |split| split.pos < 1 }
    assert { result == ['foo:bar:baz:quux'] }
  end

  test 'limit: 2' do
    result = ss.split(string, ':') { |split| split.pos < 2 }
    assert { result == %w[foo bar:baz:quux] }

    result = ss.rsplit(string, ':') { |split| split.pos < 2 }
    assert { result == %w[foo:bar:baz quux] }
  end

  test 'limit: 3' do
    result = ss.split(string, ':') { |split| split.pos < 3 }
    assert { result == %w[foo bar baz:quux] }

    result = ss.rsplit(string, ':') { |split| split.pos < 3 }
    assert { result == %w[foo:bar baz quux] }
  end
end
