# frozen_string_literal: true

require_relative 'date_testable'
require_relative 'result_testable'
require_relative 'translation_testable'

module Examples
  class Tester
    class << self
      def build(test:, example:)
        split_test = test.split('_')
        type = split_test.shift
        test_type = Object.const_get("Examples::#{type.capitalize}Testable")
        test_name = "#{type}_#{split_test.join('_')}"
        self.new(type: test_type, name: test_name, example: example)
      end
    end

    MIXEDIN_METHODS = %i[test]
    
    attr_reader :name
    
    def initialize(type:, name:, example:)
      @type = type
      extend type
      @name = name
      @example = example
    end

    def call
      run_test
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
    end

    def handle_test_success
      example.add_error(name.to_sym, nil)
    end

    def run_test
      test_passed? ? handle_test_success : handle_test_fail
    end
    
    def test_fail_mismatch
      "EXPECTED:\t#{expected_result}\nRESULT\t:#{tested_result}"
    end
    
    def test_passed?
      expected_result == tested_result
    end
  end
end
