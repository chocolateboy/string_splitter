# frozen_string_literal: true

class StringSplitter
  class Split
    attr_reader :captures, :count, :index, :lhs, :position, :rhs, :separator
    attr_writer :rhs

    alias pos position

    def initialize(captures:, lhs:, rhs:, separator:)
      @captures = captures
      @lhs = lhs
      @rhs = rhs
      @separator = separator
    end

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
      @count - @position
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
      @count + 1 - @position
    end

    alias rpos rposition

    def update!(count:, index:)
      @count = count
      @index = index
      @position = index + 1
      freeze
    end
  end
end
