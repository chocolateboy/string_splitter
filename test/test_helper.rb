# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest-power_assert'
require 'minitest/reporters'

require 'string_splitter'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

module Minitest
  class Spec
    module DSL
      # change the nested `describe` separator (defined in minitest/spec.rb).
      # e.g. for:
      #
      #   describe 'foo the bar' do
      #     describe 'baz the quux' do
      #       # ...
      #     end
      #   end
      #
      # before:
      #
      #     foo the bar::baz the quux
      #
      # after:
      #
      #     foo the bar » baz the quux

      alias old_create create

      def create(name, desc)
        old_create(name.gsub('::', ' » '), desc)
      end

      # use `test` instead of `specify` as an alias for `it`
      alias test it
    end
  end

  module Reporters
    class BaseReporter
      # fix mangled output for assertion errors by toggling the default
      # value of the "display the error's class name" option to false:
      # https://github.com/kern/minitest-reporters/issues/264

      alias old_print_info print_info

      def print_info(error, display_type = false)
        old_print_info(error, display_type)
      end
    end
  end

  class Result
    # unmangle the displayed test names (use the original description).
    # (see the definition of the `it` method in minitest/spec.rb)
    #
    # before:
    #
    #   test_0001_foo the bar
    #
    # after:
    #
    #   foo the bar
    #
    # inspired by: https://stackoverflow.com/q/24149581

    alias old_name name

    def name
      old_name.sub(/\Atest_\d+_/, '')
    end
  end
end
