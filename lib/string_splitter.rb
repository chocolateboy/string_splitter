# frozen_string_literal: true

require 'set'

require_relative 'string_splitter/split'
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
# Implementation-wise, we split the string either with String#split, or with a custom
# scanner if the delimiter may contain captures (since String#split doesn't handle
# them correctly), and parse the resulting tokens into an array of Split objects with
# the following attributes:
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

    result << splits.first.lhs

    splits.each_with_index do |split, index|
      split.update!(count: count, index: index)

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

    result.unshift(splits.last.rhs)

    splits.reverse_each.with_index do |split, index|
      split.update!(count: count, index: index)

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
  #     if the splits array is empty, the caller returns this array immediately
  #     without any further processing
  #
  #   - splits: an array of Split objects exposing the lhs, rhs, separator and
  #     captured separator substrings for each split
  #
  #   - count: the number of splits
  #
  #   - accept: a proc whose return value determines whether each split should be
  #     accepted (true) or rejected (false)
  #
  def init(string:, delimiter:, select:, reject:, block:)
    return [[]] if string.empty?

    unless block
      if reject
        positions = reject
        action = Action::REJECT
      elsif select
        positions = select
        action = Action::SELECT
      else
        block = ACCEPT_ALL
      end
    end

    # use String#split if we can
    #
    # NOTE +reject!+ is no faster than +reject+ on MRI and significantly slower
    # on TruffleRuby

    if delimiter.is_a?(String)
      limit = -1

      if delimiter == ' '
        delimiter = / / # don't trim
      elsif delimiter.empty?
        limit = 0 # remove the trailing empty string
      end

      result = string.split(delimiter, limit)

      return [result] if result.length == 1 # delimiter not found: no splits

      if block == ACCEPT_ALL # return the (2 or more) fields
        result = result.reject(&:empty?) if @remove_empty_fields
        return [result]
      end

      splits = []

      result.each_cons(2) do |lhs, rhs| # 2 or more fields
        splits << Split.new(
          captures: [],
          lhs: lhs,
          rhs: rhs,
          separator: delimiter
        )
      end
    elsif delimiter == DEFAULT_DELIMITER && block == ACCEPT_ALL
      # non-empty separators so -1 is safe

      # XXX String#split with block was introduced in Ruby 2.6:
      #
      # - https://rubyreferences.github.io/rubychanges/2.6.html#stringsplit-with-block
      #
      # rather than sniffing, we'll just use the compatible version for now
      #
      # if @remove_empty_fields
      #     result = []
      #
      #     string.split(delimiter, -1) do |field|
      #         result << field unless field.empty?
      #     end
      # else
      #     result = string.split(delimiter, -1)
      # end

      result = string.split(delimiter, -1)
      result = result.reject(&:empty?) if @remove_empty_fields
      return [result]
    else
      splits = parse(string, delimiter)
    end

    count = splits.length

    return [[string]] if count.zero?

    block ||= compile(positions, action, count)
    [[], splits, count, block]
  end

  def render(values)
    values.flat_map do |value|
      if value.is_a?(String)
        value.empty? && @remove_empty_fields ? REMOVE : [value]
      elsif @include_captures
        if @spread_captures
          # TODO make sure compact can return a Capture
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
  # the delimiter, returning an array of objects representing each split.
  # e.g. for:
  #
  #   parse("foo:bar:baz:quux", ":")
  #
  # we return:
  #
  #   [
  #       Split.new(lhs: "foo", rhs: "bar",  separator: ":", captures: []),
  #       Split.new(lhs: "bar", rhs: "baz",  separator: ":", captures: []),
  #       Split.new(lhs: "baz", rhs: "quux", separator: ":", captures: []),
  #   ]
  #
  def parse(string, delimiter)
    # has_names = delimiter.is_a?(Regexp) && !delimiter.names.empty?
    splits = []
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
      splits.last.rhs = lhs unless splits.empty?

      # this is correct for the last/only match, but gets updated to the next
      # match's lhs for other matches
      rhs = match.post_match

      # captures = has_names ? Captures.new(match) : match.captures

      splits << Split.new(
        captures: match.captures,
        lhs: lhs,
        rhs: rhs,
        separator: separator
      )

      # advance the start index (the start of the next lhs) to the position
      # after the last character of the separator
      start = after
    end

    splits
  end

  # returns a lambda which splits at (i.e. accepts or rejects splits at, depending
  # on the action) the supplied positions
  #
  # positions are preprocessed to support negative indices, infinite ranges, and
  # descending ranges, e.g.:
  #
  #   ss.split("foo:bar:baz:quux", ":", at: -1)
  #
  # translates to:
  #
  #   ss.split("foo:bar:baz:quux", ":", at: 3)
  #
  # and
  #
  #   ss.split("1:2:3:4:5:6:7:8:9", ":", at: -3..)
  #
  # translates to:
  #
  #   ss.split("1:2:3:4:5:6:7:8:9", ":", at: 6..8)
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
