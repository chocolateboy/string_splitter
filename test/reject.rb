# frozen_string_literal: true

require_relative 'test_helper'

# confirm that :reject and its :except alias reject splits at the specified (1-based)
# indices

describe 'reject' do
  ss = StringSplitter.new(default_delimiter: ':')

  test 'reject a positive position' do
    result = ss.split('foo:bar:baz:quux', except: 1)
    assert { result == %w[foo:bar baz quux] }

    result = ss.split('foo:bar:baz:quux', reject: 1)
    assert { result == %w[foo:bar baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', except: 1)
    assert { result == %w[foo bar baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', reject: 1)
    assert { result == %w[foo bar baz:quux] }
  end

  test 'reject a negative position' do
    result = ss.split('foo:bar:baz:quux', except: -1)
    assert { result == %w[foo bar baz:quux] }

    result = ss.split('foo:bar:baz:quux', reject: -1)
    assert { result == %w[foo bar baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', except: -1)
    assert { result == %w[foo:bar baz quux] }

    result = ss.rsplit('foo:bar:baz:quux', reject: -1)
    assert { result == %w[foo:bar baz quux] }
  end

  test 'reject multiple positions' do
    result = ss.split('foo:bar:baz:quux', except: [1, -1])
    assert { result == %w[foo:bar baz:quux] }

    result = ss.split('foo:bar:baz:quux', reject: [1, -1])
    assert { result == %w[foo:bar baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', except: [1, -1])
    assert { result == %w[foo:bar baz:quux] }

    result = ss.rsplit('foo:bar:baz:quux', reject: [1, -1])
    assert { result == %w[foo:bar baz:quux] }
  end
end
