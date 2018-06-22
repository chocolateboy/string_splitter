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
  ACCEPT = ->(_split) { true }
  DEFAULT_DELIMITER = /\s+/
  NO_SPLITS = []

  Split = Value.new(:captures, :count, :index, :lhs, :rhs, :separator) do
    def position
      index + 1
    end

    alias_method :offset, :index
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

  def split(string, delimiter = @default_delimiter, at: nil, &block)
    result, block, splits, count, index = split_common(string, delimiter, at, block)

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

  def rsplit(string, delimiter = @default_delimiter, at: nil, &block)
    result, block, splits, count, index = split_common(string, delimiter, at, block)

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
  def split_common(string, delimiter, at, block)
    unless (match = string.match(delimiter))
      result = (@remove_empty && string.empty?) ? [] : [string]
      return [result, block, NO_SPLITS, 0, -1]
    end

    ncaptures = match.captures.length

    if delimiter.is_a?(Regexp) && ncaptures > 0
      # increment back-references so they remain valid when the outer capture
      # is added e.g. to split on:
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
      #   %r| ( <(\w+-comment)> [^<]* </\2> ) |x

      delimiter = delimiter.to_s.gsub(/\\(?:(\d+)|.)/) do
        match = Regexp.last_match
        match[1] ? '\\' + match[1].to_i.next.to_s : match[0]
      end
    end

    parts = string.split(/(#{delimiter})/, -1)
    result, splits = splits_for(parts, ncaptures)
    count = splits.length

    unless block
      if at
        at = Array(at).map do |index|
          if index.is_a?(Integer) && index.negative?
            # translate 1-based negative indices to 1-based positive
            # indices e.g:
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
            # to mysteriously match when the index is 2

            count + 1 + index
          else
            index
          end
        end

        block = lambda do |split|
          case split.position when *at then true else false end
        end
      else
        block = ACCEPT
      end
    end

    [result, block, splits, count, -1]
  end
end
