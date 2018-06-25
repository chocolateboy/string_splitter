# frozen_string_literal: true

require_relative 'test_helper'

# confirm that :reject and its :exclude alias reject splits at the specified (1-based)
# indices

describe 'reject' do
  s = StringSplitter.new(default_delimiter: ':')

  test 'reject a positive position' do
    result = s.split('foo:bar:baz:quux', exclude: 1)
    assert { result == %w[foo:bar baz quux] }

    result = s.split('foo:bar:baz:quux', reject: 1)
    assert { result == %w[foo:bar baz quux] }
  end

  test 'reject a negative position' do
    result = s.split('foo:bar:baz:quux', exclude: -1)
    assert { result == %w[foo bar baz:quux] }

    result = s.split('foo:bar:baz:quux', reject: -1)
    assert { result == %w[foo bar baz:quux] }
  end

  test 'reject multiple positions' do
    result = s.split('foo:bar:baz:quux', exclude: [1, -1])
    assert { result == %w[foo:bar baz:quux] }

    result = s.split('foo:bar:baz:quux', reject: [1, -1])
    assert { result == %w[foo:bar baz:quux] }
  end
end