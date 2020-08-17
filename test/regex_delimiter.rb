# frozen_string_literal: true

require_relative 'test_helper'

# confirm regex delimiters work with and without captures

describe 'regex delimiter (split)' do
  test 'regex without captures' do
    ss = StringSplitter.new

    result = ss.split('foo+bar-baz:quux', /[:-]/)
    assert { result == %w[foo+bar baz quux] }

    result = ss.rsplit('foo+bar-baz:quux', /[:-]/)
    assert { result == %w[foo+bar baz quux] }
  end

  test 'regex with spread captures' do
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

  test 'regex with array captures' do
    s1 = StringSplitter.new(include_captures: false, spread_captures: false)
    s2 = StringSplitter.new(include_captures: true, spread_captures: false)

    result = s1.split('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo bar baz quux] }

    result = s1.rsplit('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo bar baz quux] }

    result = s2.split('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == ['foo', %w[X Y], 'bar', %w[X Y], 'baz', %w[X Y], 'quux'] }

    result = s2.rsplit('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == ['foo', %w[X Y], 'bar', %w[X Y], 'baz', %w[X Y], 'quux'] }
  end
end
