# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.separator contains the string matching the delimiter(s)

describe 'split.separator' do
  s = StringSplitter.new

  test 'fixed separator' do
    result = []
    s.split('foo:bar', ':') { |split| result << split.separator; true }
    assert { result == [':'] }
  end

  test 'fixed separators' do
    result = []
    s.split('foo:bar:baz:quux', ':') { |split| result << split.separator; true }
    assert { result == [':', ':', ':'] }
  end

  test 'variable separator' do
    result = []
    s.split('foo+bar', /[+-]/) { |split| result << split.separator; true }
    assert { result == ['+'] }

    result = []
    s.split('foo-bar', /[+-]/) { |split| result << split.separator; true }
    assert { result == ['-'] }
  end

  test 'variable separators' do
    result = []
    s.split('1+2-3+4-5', /[+-]/) { |split| result << split.separator; true }
    assert { result == ['+', '-', '+', '-'] }
  end
end
