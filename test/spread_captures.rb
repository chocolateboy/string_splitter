# frozen_string_literal: true

require_relative 'test_helper'

# confirm the spread_captures option works

describe 'spread_captures' do
  test 'true' do
    s1 = StringSplitter.new(include_captures: true) # default: spread_captures: true
    s2 = StringSplitter.new(include_captures: true, spread_captures: true)

    result = s1.split('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo X Y bar X Y baz X Y quux] }

    result = s2.split('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo X Y bar X Y baz X Y quux] }

    result = s1.rsplit('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo X Y bar X Y baz X Y quux] }

    result = s2.rsplit('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == %w[foo X Y bar X Y baz X Y quux] }
  end

  test 'false' do
    ss = StringSplitter.new(include_captures: true, spread_captures: false)

    result = ss.split('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == ['foo', %w[X Y], 'bar', %w[X Y], 'baz', %w[X Y], 'quux'] }

    result = ss.rsplit('fooXYbarXYbazXYquux', /(X)(Y)/)
    assert { result == ['foo', %w[X Y], 'bar', %w[X Y], 'baz', %w[X Y], 'quux'] }
  end
end
