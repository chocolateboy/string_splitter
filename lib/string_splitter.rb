# frozen_string_literal: true

require 'values'

# This class extends the functionality of +String#split+ by:
#
#   - providing full control over which splits are accepted or rejected
#   - adding support for splitting from right-to-left
#   - encapsulating splitting options/preferences in instances rather than trying to
#     cram them in to overloaded method parameters
#
# These enhancements allow splits to handle many cases that otherwise require bigger
# guns e.g. regex matching or parsing.
class StringSplitter
  ACCEPT = ->(_index, _split) { true }

  Split = Value.new(:captures, :lhs, :rhs, :separator)

  # TODO: add default_separator
  def initialize(include_captures: true, remove_empty: false, spread_captures: true)
    @include_captures = include_captures
    @remove_empty = remove_empty
    @spread_captures = spread_captures
  end

  def split(string, delimiter = /\s+/, at: nil, &block)
    result, block, iterator, index = split_common(string, delimiter, at, block, :forward)

    return result unless iterator

    iterator.each do |split|
      next if @remove_empty && split.rhs.empty?

      if result.empty?
        next if @remove_empty && split.lhs.empty?
        result << split.lhs
      end

      index += 1

      if block.call(index, split)
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

  def rsplit(string, delimiter = /\s+/, at: nil, &block)
    result, block, iterator, index = split_common(string, delimiter, at, block, :reverse)

    return result unless iterator

    iterator.each do |split|
      next if @remove_empty && split.lhs.empty?

      if result.empty?
        next if @remove_empty && split.rhs.empty?
        result.unshift(split.rhs)
      end

      index += 1

      if block.call(index, split)
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

  def forward_iterator(parts, ncaptures)
    parts = parts.dup

    Enumerator.new do |yielder|
      until parts.empty?
        lhs = parts.shift
        separator = parts.shift
        captures = parts.shift(ncaptures)
        rhs = parts.length == 1 ? parts.shift : parts.first

        yielder << Split.with({
          lhs: lhs,
          rhs: rhs,
          separator: separator,
          captures: captures,
        })
      end
    end
  end

  def reverse_iterator(parts, ncaptures)
    parts = parts.dup

    Enumerator.new do |yielder|
      until parts.empty?
        rhs = parts.pop
        captures = parts.pop(ncaptures)
        separator = parts.pop
        lhs = parts.length == 1 ? parts.pop : parts.last

        yielder << Split.with({
          lhs: lhs,
          rhs: rhs,
          separator: separator,
          captures: captures,
        })
      end
    end
  end

  # setup common to both split methods
  def split_common(string, delimiter, at, block, type)
    unless (match = string.match(delimiter))
      result = (@remove_empty && string.empty?) ? [] : [string]
      return [result]
    end

    unless block
      if at
        block = lambda do |index, _split|
          case index when *at then true else false end
        end
      else
        block = ACCEPT
      end
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
    iterator = method("#{type}_iterator".to_sym).call(parts, ncaptures)
    [[], block, iterator, 0]
  end
end
