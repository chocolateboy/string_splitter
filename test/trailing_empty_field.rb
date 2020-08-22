# frozen_string_literal: true

require_relative 'test_helper'

# make sure we don't keep String#split's trailing empty field when the separator
# is empty: https://github.com/chocolateboy/string_splitter/issues/1

describe 'remove the trailing empty field' do
  s1 = StringSplitter.new(remove_empty_fields: false, include_captures: false)
  s2 = StringSplitter.new(remove_empty_fields: false, include_captures: true)
  string = 'foobar'

  test 'empty delimiter string' do
    result = s1.split(string, '')
    assert { result == %w[f o o b a r] }

    result = s2.split(string, '')
    assert { result == %w[f o o b a r] }

    result = s1.rsplit(string, '')
    assert { result == %w[f o o b a r] }

    result = s2.rsplit(string, '')
    assert { result == %w[f o o b a r] }
  end

  test 'empty delimiter pattern (no captures)' do
    result = s1.split(string, //)
    assert { result == %w[f o o b a r] }

    result = s2.split(string, //)
    assert { result == %w[f o o b a r] }

    result = s1.rsplit(string, //)
    assert { result == %w[f o o b a r] }

    result = s2.rsplit(string, //)
    assert { result == %w[f o o b a r] }
  end

  test 'empty delimiter pattern (one capture)' do
    result = s1.split(string, /()/)
    assert { result == %w[f o o b a r] }

    result = s2.split(string, /()/)
    assert { result == ['f', '', 'o', '', 'o', '', 'b', '', 'a', '', 'r'] }

    result = s1.rsplit(string, /()/)
    assert { result == %w[f o o b a r] }

    result = s2.rsplit(string, /()/)
    assert { result == ['f', '', 'o', '', 'o', '', 'b', '', 'a', '', 'r'] }
  end

  test 'empty delimiter pattern (sequential captures)' do
    result = s1.split(string, /()()/)
    assert { result == %w[f o o b a r] }

    result = s2.split(string, /()()/)
    assert { result == ['f', '', '', 'o', '', '', 'o', '', '', 'b', '', '', 'a', '', '', 'r'] }

    result = s1.rsplit(string, /()()/)
    assert { result == %w[f o o b a r] }

    result = s2.rsplit(string, /()()/)
    assert { result == ['f', '', '', 'o', '', '', 'o', '', '', 'b', '', '', 'a', '', '', 'r'] }
  end

  test 'empty delimiter pattern (nested captures)' do
    result = s1.split(string, /(())/)
    assert { result == %w[f o o b a r] }

    result = s2.split(string, /(())/)
    assert { result == ['f', '', '', 'o', '', '', 'o', '', '', 'b', '', '', 'a', '', '', 'r'] }

    result = s1.rsplit(string, /(())/)
    assert { result == %w[f o o b a r] }

    result = s2.rsplit(string, /(())/)
    assert { result == ['f', '', '', 'o', '', '', 'o', '', '', 'b', '', '', 'a', '', '', 'r'] }
  end
end
