# frozen_string_literal: true

require_relative "../error_util"
require_relative "date_testable"
require_relative "result_testable"
require_relative "translation_testable"

module Emendate
  module Examples
    class Tester
      class << self
        # @param test [String] test name
        # @param example [Emendate::Examples::TestableExample]
        def build(test:, example:)
          split_test = test.split("_")
          type = split_test.shift
          test_type = Object.const_get("Emendate::Examples::#{type.capitalize}Testable")
          test_name = "#{type}_#{split_test.join("_")}"
          new(type: test_type, name: test_name, example: example)
        end
      end

      MIXEDIN_METHODS = %i[test]

      attr_reader :name

      # @param type [Constant] Module that will be mixed in to run test. Set by Tester.build from first part of test name
      # @param name [String] test name
      # @param example [Emendate::Examples::TestableExample]
      def initialize(type:, name:, example:)
        @type = type
        extend type
        @name = name
        @example = example
      end

      def call
        run_test
      rescue => err
        example.add_error(name.to_s, Emendate::ErrorUtil.msg(err))
        example.add_test_result(name.to_s, :failure)
      end

      def method_missing(symbol, *args)
        msg = "#{symbol} needs to be defined in #{type}"
        fail(NoMethodError.new(msg))
      rescue
        super(symbol, *args)
      end

      def to_s
        "#{self.class.name}, name: #{name}"
      end
      alias_method :inspect, :to_s

      private

      attr_reader :type, :example

      def handle_test_fail
        example.add_error(name.to_sym, test_fail_mismatch)
        example.add_test_result(name.to_sym, :failure)
      end

      def handle_test_success
        example.add_test_result(name.to_sym, :success)
      end

      def run_test
        test_passed? ? handle_test_success : handle_test_fail
      end

      def test_fail_mismatch
        ["EXPECTED: #{expected_result}",
          "RESULT:   #{tested_result}"]
      end

      def test_passed?
        expected_result == tested_result
      end
    end
  end
end
