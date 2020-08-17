# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.separator contains the string matching the delimiter(s)

describe 'split.separator' do
  ss = StringSplitter.new

  test 'fixed separator' do
    result = []
    ss.split('foo:bar', ':') { |split| result << split.separator; true }
    assert { result == [':'] }

    result = []
    ss.rsplit('foo:bar', ':') { |split| result << split.separator; true }
    assert { result == [':'] }
  end

  test 'fixed separators' do
    result = []
    ss.split('foo:bar:baz:quux', ':') { |split| result << split.separator; true }
    assert { result == [':', ':', ':'] }

    result = []
    ss.rsplit('foo:bar:baz:quux', ':') { |split| result << split.separator; true }
    assert { result == [':', ':', ':'] }
  end

  test 'variable separator' do
    result = []
    ss.split('foo+bar', /[+-]/) { |split| result << split.separator; true }
    assert { result == ['+'] }

    result = []
    ss.split('foo-bar', /[+-]/) { |split| result << split.separator; true }
    assert { result == ['-'] }
  end

  test 'variable separators' do
    result = []
    ss.split('1+2-3+4-5', /[+-]/) { |split| result << split.separator; true }
    assert { result == %w[+ - + -] }

    result = []
    ss.rsplit('1+2-3+4-5', /[+-]/) { |split| result << split.separator; true }
    assert { result == %w[- + - +] }
  end
end
