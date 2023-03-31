# frozen_string_literal: true

module Emendate
  module Examples
    # Mixin module for Examples::Tester
    module DateTestable

      def expected_result
        return nil unless example.testable?

        example.rows
          .map{ |row| row.send(name.to_sym) }
          .map{ |val| val.start_with?('Date') ? instance_eval(val) : val }
          .join('|')
      end

      def tested_result
        return nil unless example.testable?
        return 'nilValue' if example.processed.result.dates.empty?

        example.processed.result.dates
          .map{ |date| date.send(name.to_sym) }
          .map{ |date| date.nil? ? 'nilValue' : date }
          .join('|')
      end
    end
  end
end
