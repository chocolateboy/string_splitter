# frozen_string_literal: true

require_relative 'test_helper'

# confirm regex delimiters work as expected

describe 'regex delimiter' do
  test 'regex without captures' do
    s = StringSplitter.new

    result = s.split('foo+bar-baz:quux', /[:-]/)
    assert { result == %w[foo+bar baz quux] }

    result = s.rsplit('foo+bar-baz:quux', /[:-]/)
    assert { result == %w[foo+bar baz quux] }
  end

  test 'regex with captures' do
    s1 = StringSplitter.new(include_captures: false)
    s2 = StringSplitter.new(include_captures: true)

    result = s1.split('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo bar baz quux] }

    result = s1.rsplit('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo bar baz quux] }

    result = s2.split('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo X Y bar X Y baz X Y quux] }

    result = s2.rsplit('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo X Y bar X Y baz X Y quux] }
  end
end
