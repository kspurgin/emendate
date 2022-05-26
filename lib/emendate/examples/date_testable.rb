# frozen_string_literal: true

module Emendate
  module Examples
    # Mixin module for Examples::Tester
    module DateTestable

      def expected_result
        return nil unless example.testable?

        example.rows
          .map{ |row| row.send(name.to_sym) }
          .join('|')
      end

      def tested_result
        return nil unless example.testable?

        example.processed.result.dates
          .map{ |date| date.send(name.to_sym) }
          .join('|')
      end
    end
  end
end
