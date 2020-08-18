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
# Implementation-wise, we effectively use the built-in +String#split+ method as a
# tokenizer, and parse the resulting tokens into an array of Split objects with the
# following fields:
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
  DONE = Object.new
  DEFAULT_DELIMITER = /\s+/
  NO_SPLITS = []

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
    result, splits, accept = init(
      string: string,
      delimiter: delimiter,
      select: select,
      reject: reject,
      block: block
    )

    count = splits.length

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
    result, splits, accept = init(
      string: string,
      delimiter: delimiter,
      select: select,
      reject: reject,
      block: block
    )

    return result if accept == DONE

    count = splits.length

    splits.reverse!.each_with_index do |hash, index|
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

  def render(result)
    if @remove_empty_fields
      result.reject! { |it| it.is_a?(String) && it.empty? }
    end

    unless @include_captures
      return result.reject! { |it| it.is_a?(Array) }
    end

    result.flat_map do |value|
      next [value] unless value.is_a?(Array) && @spread_captures
      @spread_captures == :compact ? value.compact : value
    end
  end

  # converts the tokens returned by
  #
  #   string.split(delimiter)
  #
  # into an array of objects (hashes) representing each split. e.g. for:
  #
  #   ss.split("foo:bar:baz:quux", ":")
  #
  # it's called with:
  #
  #   splits_for(["foo", ":", "bar", ":", "baz", ":", "quux"], 0)
  #
  # and returns:
  #
  #   [
  #       { lhs: "foo", rhs: "bar", separator: ":", captures: [] },
  #       { lhs: "bar", rhs: "baz", separator: ":", captures: [] },
  #       { lhs: "baz", rhs: "quux", separator: ":", captures: [] },
  #   ]

  def splits_for(parts, ncaptures)
    splits = []
    rhs = nil

    until parts.empty?
      lhs = rhs || parts.shift
      separator = parts.shift
      captures = parts.shift(ncaptures)
      rhs = parts.shift

      # there's no such thing as an empty field whose separator is empty, so if
      # String#split's result ends with an empty separator, 0 or more (empty)
      # captures and an empty field, we can safely remove them.
      break if parts.empty? && separator.empty? && rhs.empty?

      splits << {
        lhs: lhs,
        rhs: rhs,
        separator: separator,
        captures: captures,
      }
    end

    splits
  end

  # takes a hash of options passed to +split+ or +rsplit+ and returns a triple with
  # the following fields:
  #
  #   - result: the array of separated strings to return from +split+ or +rsplit+
  #     if the accept value is DONE, the caller returns this array immediately
  #     without any further processing
  #
  #   - splits: an array of hashes containing the lhs, rhs, separator and captured
  #     separator substrings for each split
  #
  #   - accept: a proc whose return value determines whether each split should be
  #     accepted (true) or rejected (false)

  def init(string:, delimiter:, select:, reject:, block:)
    return [[], NO_SPLITS, DONE] if string.empty?

    if delimiter.is_a?(String)
      match = string.include?(delimiter)
      ncaptures = 0
    elsif (match = string.match(delimiter))
      ncaptures = match.captures.length
    end

    return [[string], NO_SPLITS, DONE] unless match

    # XXX must be done *after* the include? test
    delimiter = Regexp.quote(delimiter) if delimiter.is_a?(String)

    if reject
      positions = reject
      action = Action::REJECT
    elsif select
      positions = select
      action = Action::SELECT
    end

    delimiter = increment_backrefs(/(#{delimiter})/)
    parts = string.split(delimiter, -1)
    splits = splits_for(parts, ncaptures)
    block ||= positions ? match_positions(positions, action, splits.length) : ACCEPT_ALL
    [[], splits, block]
  end

  # increment back-references so they remain valid when the outer capture
  # is added.
  #
  # e.g. to split on:
  #
  #   - <foo-comment> ... </foo-comment>
  #   - <bar-comment> ... </bar-comment>
  #
  # etc.
  #
  # before:
  #
  #   %r|   <(\w+-comment)> [^<]* </\1>   |x
  #
  # after:
  #
  #       +------- outer capture -------+
  #       |                             |
  #       v                             v
  #   %r| ( <(\w+-comment)> [^<]* </\2> ) |x

  def increment_backrefs(delimiter)
    delimiter = delimiter.to_s.gsub(/\\(?:(\d+)|.)/) do
      match = Regexp.last_match
      match[1] ? '\\' + match[1].to_i.next.to_s : match[0]
    end

    Regexp.new(delimiter)
  end

  def match_positions(positions, action, nsplits)
    # translate negative indices to 1-based non-negative indices, e.g:
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
    # XXX note: we don't use modulo, because we don't want
    # out-of-bounds indices to silently work, e.g. we don't want:
    #
    #   ss.split("foo:bar:baz:quux", ":", at: -42)
    #
    # to mysteriously match when the index/position is 0/1

    resolve = ->(int) { int.negative? ? nsplits + 1 + int : int }

    # don't use Array(...) to wrap these as we don't want to convert ranges
    positions = positions.is_a?(Array) ? positions : [positions]

    positions = positions.map do |position|
      if position.is_a?(Integer)
        position.negative? ? resolve[position] : position
      elsif position.is_a?(Range)
        if position.begin.nil?
          position = Range.new(1, resolve[position.end], position.exclude_end?)
        elsif position.end.nil?
          position = Range.new(resolve[position.begin], nsplits, position.exclude_end?)
        else
          from = resolve[position.begin]
          to = resolve[position.end]

          if to < from
            position = Range.new(to, from, position.exclude_end?)
          else
            position = Range.new(from, to, position.exclude_end?)
          end
        end

        position
      elsif position.is_a?(Set)
        position.map { |it| resolve(it) }.to_set
      else
        position
      end
    end

    ->(split) { case split.position when *positions then action else !action end }
  end
end
