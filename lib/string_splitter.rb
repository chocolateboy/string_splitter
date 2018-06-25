# frozen_string_literal: true

require 'values'

# This class extends the functionality of +String#split+ by:
#
#   - providing full control over which splits are accepted or rejected
#   - adding support for splitting from right-to-left
#   - encapsulating splitting options/preferences in instances rather than trying to
#     cram them into overloaded method parameters
#
# These enhancements allow splits to handle many cases that otherwise require bigger
# guns e.g. regex matching or parsing.
class StringSplitter
  ACCEPT_ALL = ->(_split) { true }
  DEFAULT_DELIMITER = /\s+/
  NO_SPLITS = []

  Split = Value.new(:captures, :count, :index, :lhs, :rhs, :separator) do
    def position
      index + 1
    end

    alias_method :pos, :position
  end

  def initialize(
    default_delimiter: DEFAULT_DELIMITER,
    include_captures: true,
    remove_empty: false,
    spread_captures: true
  )
    @default_delimiter = default_delimiter
    @include_captures = include_captures
    @remove_empty = remove_empty
    @spread_captures = spread_captures
  end

  attr_reader :default_delimiter, :include_captures, :remove_empty, :spread_captures

  def split(
    string,
    delimiter = @default_delimiter,
    at: nil,
    select: at,
    exclude: nil,
    reject: exclude,
    &block
  )
    result, block, splits, count, index = split_common(
      string: string,
      delimiter: delimiter,
      select: select,
      reject: reject,
      block: block
    )

    splits.each do |split|
      split = Split.with(split.merge({ index: (index += 1), count: count }))
      result << split.lhs if result.empty?

      if block.call(split)
        if @include_captures
          if @spread_captures
            result += split.captures
          else
            result << split.captures
          end
        end

        result << split.rhs
      else
        # append the rhs
        result[-1] = result[-1] + split.separator + split.rhs
      end
    end

    result
  end

  alias lsplit split

  def rsplit(
    string,
    delimiter = @default_delimiter,
    at: nil,
    select: at,
    exclude: nil,
    reject: exclude,
    &block
  )
    result, block, splits, count, index = split_common(
      string: string,
      delimiter: delimiter,
      select: select,
      reject: reject,
      block: block
    )

    splits.reverse!.each do |split|
      split = Split.with(split.merge({ index: (index += 1), count: count }))
      result.unshift(split.rhs) if result.empty?

      if block.call(split)
        if @include_captures
          if @spread_captures
            result = split.captures + result
          else
            result.unshift(split.captures)
          end
        end

        result.unshift(split.lhs)
      else
        # prepend the lhs
        result[0] = split.lhs + split.separator + result[0]
      end
    end

    result
  end

  private

  def splits_for(parts, ncaptures)
    result = []
    splits = []

    until parts.empty?
      lhs = parts.shift
      separator = parts.shift
      captures = parts.shift(ncaptures)
      rhs = parts.length == 1 ? parts.shift : parts.first

      if @remove_empty && (lhs.empty? || rhs.empty?)
        if lhs.empty? && rhs.empty?
          # do nothing
        elsif parts.empty? # last split
          result << (!lhs.empty? ? lhs : rhs) if splits.empty?
        elsif rhs.empty?
          # replace the empty rhs with the non-empty lhs
          parts[0] = lhs
        end

        next
      end

      splits << {
        lhs: lhs,
        rhs: rhs,
        separator: separator,
        captures: captures,
      }
    end

    [result, splits]
  end

  # setup common to both split methods
  def split_common(string:, delimiter:, select:, reject:, block:)
    unless (match = string.match(delimiter))
      result = (@remove_empty && string.empty?) ? [] : [string]
      return [result, block, NO_SPLITS, 0, -1]
    end

    select = Array(select)
    reject = Array(reject)

    if !reject.empty?
      positions = reject
      action = :reject
    elsif !select.empty?
      positions = select
      action = :select
    end

    ncaptures = match.captures.length
    delimiter = Regexp.quote(delimiter) if delimiter.is_a?(String)
    delimiter = increment_backrefs(delimiter, ncaptures)
    parts = string.split(/(#{delimiter})/, -1)
    remove_trailing_empty_field!(parts, ncaptures)
    result, splits = splits_for(parts, ncaptures)
    count = splits.length
    block ||= positions ? match_positions(positions, action, count) : ACCEPT_ALL

    [result, block, splits, count, -1]
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
  #   %r|   <(\w+-comment)> [^<]* </\1-comment>   |x
  #
  # after:
  #
  #   %r| ( <(\w+-comment)> [^<]* </\2-comment> ) |x

  def increment_backrefs(delimiter, ncaptures)
    if delimiter.is_a?(Regexp) && ncaptures > 0
      delimiter = delimiter.to_s.gsub(/\\(?:(\d+)|.)/) do
        match = Regexp.last_match
        match[1] ? '\\' + match[1].to_i.next.to_s : match[0]
      end
    end

    delimiter
  end

  # work around Ruby's (and Perl's and Groovy's) unhelpful behavior when splitting
  # on an empty string/pattern without removing trailing empty fields e.g.:
  #
  #   "foobar".split("", -1)
  #   "foobar".split(//, -1)
  #   # => ["f", "o", "o", "b", "a", "r", ""]
  #
  #   "foobar".split(/()/, -1)
  #   # => ["f", "", "o", "", "o", "", "b", "", "a", "", "r", "", ""]
  #
  #   "foobar".split(/(())/, -1)
  #   # => ["f", "", "", "o", "", "", "o", "", "", "b", "", "", "a", "", "", "r", "", "", ""]
  #
  # *there is no such thing as an empty field whose separator is empty*, so
  # if String#split's result ends with an empty separator, 0 or more (empty)
  # captures and an empty field, we can safely remove them.

  def remove_trailing_empty_field!(parts, ncaptures)
    # the trailing field is at index -1. if there are 0 captures, the separator
    # is at -2:
    #
    #   [empty_separator, empty_field]
    #
    # if there is 1 capture, the separator is at -3:
    #
    #   [empty_separator, capture, empty_field]
    #
    # etc. therefore we find the separator by walking back
    #
    #  1 (empty field)
    #  + ncaptures
    #  + 1 (separator)
    #
    # steps from the end of the array i.e. ncaptures + 2
    count = ncaptures + 2
    separator_index = count * -1

    return unless parts[-1].empty? && parts[separator_index].empty?

    # drop the empty separator, the (empty) captures, and the trailing empty field
    parts.pop(count)
  end

  def match_positions(positions, action, nsplits)
    positions = Array(positions).map do |position|
      if position.is_a?(Integer) && position.negative?
        # translate negative indices to 1-based non-negative indices e.g:
        #
        #   ss.split("foo:bar:baz:quux", ":", at: -1)
        #
        # translates to:
        #
        #   ss.split("foo:bar:baz:quux", ":", at: 3)
        #
        # XXX note: we don't use modulo, because we don't want
        # out-of-bounds indices to silently work e.g. we don't want:
        #
        #   ss.split("foo:bar:baz:quux", ":", -42)
        #
        # to mysteriously match when the position is 2

        nsplits + 1 + position
      else
        position
      end
    end

    match = action == :select

    lambda do |split|
      case split.position when *positions then match else !match end
    end
  end
end
