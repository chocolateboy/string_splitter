# frozen_string_literal: true

require_relative 'test_helper'

# confirm split.rhs contains the field after the split

string = 'head begin:foo skip me end:foo blah blah blah <tag> skip me too </tag> tail'
re = %r{ ( ( begin:(\w+) .+? end:\3 ) | ( <(\w+)> .+? </\5> ) ) }x

describe 'backrefs' do
  test 'include captures' do
    skip 'todo'

    ss = StringSplitter.new(include_captures: true, spread_captures: false)

    want = [
      'head ',
      ['begin:foo skip me end:foo', 'begin:foo skip me end:foo', 'foo', '', ''],
      ' blah blah blah ',
      ['<tag> skip me too</tag>', '', '', '<tag> skip me too</tag>', 'tag'],
      ' tail'
    ]

    assert { ss.split(string, re) == want }
    assert { ss.split(string, re) == want }

    assert { ss.rsplit(string, re) == want }
    assert { ss.rsplit(string, re) == want }
  end

  test 'remove captures' do
    skip 'todo'

    ss = StringSplitter.new(include_captures: false)

    want = ['head ', ' blah blah blah', ' tail']

    assert { ss.split(string, re) == want }
    assert { ss.split(string, re) == want }

    assert { ss.rsplit(string, re) == want }
    assert { ss.rsplit(string, re) == want }
  end
end
