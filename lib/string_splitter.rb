# frozen_string_literal: true

require 'set'
require 'values'

require_relative 'string_splitter/version'

# This class extends the functionality of +String#split+ by:
#
#   - providing full control over which splits are accepted or rejected
#
#   - adding support for splitting from right-to-left
#
#   - encapsulating splitting options/preferences in the splitter rather
#     than trying to cram them into overloaded method parameters
#
# These enhancements allow splits to handle many cases that otherwise require bigger
# guns, e.g. regex matching or parsing.
#
# Implementation-wise, we split the string with a scanner which works in a similar
# way to +String#split+ and parse the resulting tokens into an array of Split objects
# with the following fields:
#
#   - captures:  separator substrings captured by parentheses in the delimiter pattern
#   - count:     the number of splits
#   - index:     the 0-based index of the split in the array
#   - lhs:       the string to the left of the separator (back to the previous split candidate)
#   - position:  the 1-based index of the split in the array (alias: pos)
#   - rhs:       the string to the right of the separator (up to the next split candidate)
#   - rindex:    the 0-based index of the split relative to the end of the array
#   - rposition: the 1-based index of the split relative to the end of the array (alias: rpos)
#   - separator: the string matched by the delimiter pattern/string
#
class StringSplitter
  # terminology: the delimiter is what we provide and the separators are what we get
  # back (if we capture them). e.g. for:
  #
  #   ss.split("foo:bar::baz", /(\W+)/)
  #
  # the delimiter is /(\W)/ and the separators are ":" and "::"

  ACCEPT_ALL = ->(_split) { true }
  DEFAULT_DELIMITER = /\s+/.freeze
  REMOVE = [].freeze

  Split = Value.new(:captures, :count, :index, :lhs, :rhs, :separator) do
    def position
      index + 1
    end

    alias_method :pos, :position

    # 0-based index relative to the end of the array, e.g. for 5 items:
    #
    #  index | rindex
    #  ------|-------
    #    0   |   4
    #    1   |   3
    #    2   |   2
    #    3   |   1
    #    4   |   0
    def rindex
      count - position
    end

    # 1-based position relative to the end of the array, e.g. for 5 items:
    #
    #   position | rposition
    #  ----------|----------
    #      1     |    5
    #      2     |    4
    #      3     |    3
    #      4     |    2
    #      5     |    1
    def rposition
      count + 1 - position
    end

    alias_method :rpos, :rposition
  end

  # simulate an enum. the value is returned by the case statement
  # in the generated block if the positions match
  module Action
    SELECT = true
    REJECT = false
  end

  private_constant :Action

  def initialize(
    default_delimiter: DEFAULT_DELIMITER,
    include_captures: true,
    remove_empty: false, # TODO remove this
    remove_empty_fields: remove_empty,
    spread_captures: true
  )
    @default_delimiter = default_delimiter
    @include_captures = include_captures
    @remove_empty_fields = remove_empty_fields
    @spread_captures = spread_captures
  end

  attr_reader(
    :default_delimiter,
    :include_captures,
    :remove_empty_fields,
    :spread_captures
  )

  # TODO remove this
  alias remove_empty remove_empty_fields

  def split(
    string,
    delimiter = @default_delimiter,
    at: nil, # alias for select
    except: nil, # alias for reject
    select: at,
    reject: except,
    &block
  )
    result, splits, count, accept = init(
      string: string,
      delimiter: delimiter,
      select: select,
      reject: reject,
      block: block
    )

    return result unless splits

    splits.each_with_index do |hash, index|
      split = Split.with(hash.merge({ count: count, index: index }))
      result << split.lhs if result.empty?

      if accept.call(split)
        result << split.captures << split.rhs
      else
        # append the rhs
        result[-1] = result[-1] + split.separator + split.rhs
      end
    end

    render(result)
  end

  alias lsplit split

  def rsplit(
    string,
    delimiter = @default_delimiter,
    at: nil, # alias for select
    except: nil, # alias for reject
    select: at,
    reject: except,
    &block
  )
    result, splits, count, accept = init(
      string: string,
      delimiter: delimiter,
      select: select,
      reject: reject,
      block: block
    )

    return result unless splits

    splits.reverse_each.with_index do |hash, index|
      split = Split.with(hash.merge({ count: count, index: index }))
      result.unshift(split.rhs) if result.empty?

      if accept.call(split)
        # [lhs + captures] + result
        result.unshift(split.lhs, split.captures)
      else
        # prepend the lhs
        result[0] = split.lhs + split.separator + result[0]
      end
    end

    render(result)
  end

  private

  # initialisation common to +split+ and +rsplit+
  #
  # takes a hash of options passed to +split+ or +rsplit+ and returns a tuple with
  # the following fields:
  #
  #   - result: the array of separated strings to return from +split+ or +rsplit+.
  #     if the splits arry is empty, the caller returns this array immediately
  #     without any further processing
  #
  #   - splits: an array of hashes containing the lhs, rhs, separator and captured
  #     separator substrings for each split
  #
  #   - count: the number of splits
  #
  #   - accept: a proc whose return value determines whether each split should be
  #     accepted (true) or rejected (false)
  #
  def init(string:, delimiter:, select:, reject:, block:)
    if delimiter.equal?(DEFAULT_DELIMITER)
      string = string.strip
    end

    if reject
      positions = reject
      action = Action::REJECT
    elsif select
      positions = select
      action = Action::SELECT
    end

    splits = parse(string, delimiter)

    if splits.empty?
      result = string.empty? ? [] : [string]
      return [result]
    end

    block ||= positions ? compile(positions, action, splits.length) : ACCEPT_ALL
    [[], splits, splits.length, block]
  end

  def render(values)
    values.flat_map do |value|
      if value.is_a?(String)
        value.empty? && @remove_empty_fields ? REMOVE : [value]
      elsif @include_captures
        if @spread_captures
          @spread_captures == :compact ? value.compact : value
        elsif value.empty?
          # we expose non-captures (string delimiters or regexps with no
          # captures) as empty arrays inside the block, so the type is
          # consistent, but it doesn't make sense to keep them in the
          # result
          REMOVE
        else
          [value]
        end
      else
        REMOVE
      end
    end
  end

  # takes a string and a delimiter pattern (regex or string) and splits it along
  # the delimiter, returning an array of objects (hashes) representing each split.
  # e.g. for:
  #
  #   parse.split("foo:bar:baz:quux", ":")
  #
  # we return:
  #
  #   [
  #       { lhs: "foo", rhs: "bar", separator: ":", captures: [] },
  #       { lhs: "bar", rhs: "baz", separator: ":", captures: [] },
  #       { lhs: "baz", rhs: "quux", separator: ":", captures: [] },
  #   ]
  #
  def parse(string, delimiter)
    result = []
    start = 0

    # we don't use the argument passed to the +scan+ block here because it's a
    # string (the separator) if there are no captures, rather than an empty
    # array. we use match.captures instead to get the array
    string.scan(delimiter) do
      match = Regexp.last_match
      index, after = match.offset(0)
      separator = match[0]

      # ignore empty separators at the beginning and/or end of the string
      next if separator.empty? && (index.zero? || after == string.length)

      lhs = string.slice(start, index - start)
      result.last[:rhs] = lhs unless result.empty?

      # this is correct for the last/only match, but gets updated to the next
      # match's lhs for other matches
      rhs = match.post_match

      result << {
        captures: match.captures,
        lhs: lhs,
        rhs: rhs,
        separator: separator,
      }

      # move the start index (the start of the next lhs) to the index after the
      # last character of the separator
      start = after
    end

    result
  end

  # returns a lambda which splits at (i.e. accepts or rejects splits at, depending
  # on the action) the supplied positions
  #
  # positions are preprocessed to support an additional feature: negative indices
  # are translated to 1-based non-negative indices, e.g:
  #
  #   ss.split("foo:bar:baz:quux", ":", at: -1)
  #
  # translates to:
  #
  #   ss.split("foo:bar:baz:quux", ":", at: 3)
  #
  # and
  #
  #   ss.split("1:2:3:4:5:6:7:8:9", ":", -3..)
  #   ss.split("1:2:3:4:5:6:7:8:9", ":", -3..)
  #
  # translate to:
  #
  #   ss.split("foo:bar:baz:quux", ":", at: 6..8)
  #
  def compile(positions, action, count)
    # XXX note: we don't use modulo, because we don't want
    # out-of-bounds indices to silently work, e.g. we don't want:
    #
    #   ss.split("foo:bar:baz:quux", ":", at: -42)
    #
    # to mysteriously match when the index/position is 0/1
    #
    resolve = ->(int) { int.negative? ? count + 1 + int : int }

    # don't use Array(...) to wrap these as we don't want to convert ranges
    positions = positions.is_a?(Array) ? positions : [positions]

    positions = positions.map do |position|
      if position.is_a?(Integer)
        resolve[position]
      elsif position.is_a?(Range)
        rbegin = position.begin
        rend = position.end
        rexc = position.exclude_end?

        if rbegin.nil?
          Range.new(1, resolve[rend], rexc)
        elsif rend.nil?
          Range.new(resolve[rbegin], count, rexc)
        elsif rbegin.negative? || rend.negative? || (rend - rbegin).negative?
          from = resolve[rbegin]
          to = resolve[rend]
          to < from ? Range.new(to, from, rexc) : Range.new(from, to, rexc)
        else
          position
        end
      elsif position.is_a?(Set)
        position.map { |it| resolve[it] }.to_set
      else
        position
      end
    end

    ->(split) { case split.position when *positions then action else !action end }
  end
end
