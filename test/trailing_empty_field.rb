# frozen_string_literal: true

require_relative 'test_helper.rb'

# make sure we don't keep String#split's trailing empty field when the separator
# is empty: https://github.com/chocolateboy/string_splitter/issues/1

describe 'remove the trailing empty field' do
  s = StringSplitter.new(remove_empty: false, include_captures: false)
  ss = StringSplitter.new(remove_empty: false, include_captures: true)
  string = 'foobar'

  specify 'empty delimiter string' do
    result = s.split(string, '')
    assert { result == ['f', 'o', 'o', 'b', 'a', 'r'] }

    result = ss.split(string, '')
    assert { result == ['f', 'o', 'o', 'b', 'a', 'r'] }
  end

  specify 'empty delimiter pattern (no captures)' do
    result = s.split(string, //)
    assert { result == ['f', 'o', 'o', 'b', 'a', 'r'] }

    result = ss.split(string, //)
    assert { result == ['f', 'o', 'o', 'b', 'a', 'r'] }
  end

  specify 'empty delimiter pattern (one capture)' do
    result = s.split(string, /()/)
    assert { result == ['f', 'o', 'o', 'b', 'a', 'r'] }

    result = ss.split(string, /()/)
    assert { result == ['f', '', 'o', '', 'o', '', 'b', '', 'a', '', 'r'] }
  end

  specify 'empty delimiter pattern (sequential captures)' do
    result = s.split(string, /()()/)
    assert { result == ['f', 'o', 'o', 'b', 'a', 'r'] }

    result = ss.split(string, /()()/)
    assert { result == ['f', '', '', 'o', '', '', 'o', '', '', 'b', '', '', 'a', '', '', 'r'] }
  end

  specify 'empty delimiter pattern (nested captures)' do
    result = s.split(string, /(())/)
    assert { result == ['f', 'o', 'o', 'b', 'a', 'r'] }

    result = ss.split(string, /(())/)
    assert { result == ['f', '', '', 'o', '', '', 'o', '', '', 'b', '', '', 'a', '', '', 'r'] }
  end
end
