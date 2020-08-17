# frozen_string_literal: true

require_relative 'test_helper'

# confirm that :select and its :at alias accept splits at the specified (1-based)
# indices

describe 'select' do
  ss = StringSplitter.new(default_delimiter: ':')

  test 'select a positive position' do
    result = ss.split('foo:bar:baz:quux', at: 1)
    assert { result == %w[foo bar:baz:quux] }

    result = ss.split('foo:bar:baz:quux', select: 1)
    assert { result == %w[foo bar:baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', at: 1)
    assert { result == %w[foo:bar:baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', select: 1)
    assert { result == %w[foo:bar:baz quux] }
  end

  test 'select a negative position' do
    result = ss.split('foo:bar:baz:quux', at: -1)
    assert { result == %w[foo:bar:baz quux] }

    result = ss.split('foo:bar:baz:quux', select: -1)
    assert { result == %w[foo:bar:baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', at: -1)
    assert { result == %w[foo bar:baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', select: -1)
    assert { result == %w[foo bar:baz:quux] }
  end

  test 'select multiple positions' do
    result = ss.split('foo:bar:baz:quux', at: [1, -1])
    assert { result == %w[foo bar:baz quux] }

    result = ss.split('foo:bar:baz:quux', select: [1, -1])
    assert { result == %w[foo bar:baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', at: [1, -1])
    assert { result == %w[foo bar:baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', select: [1, -1])
    assert { result == %w[foo bar:baz quux] }
  end
end
