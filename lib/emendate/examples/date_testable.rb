# frozen_string_literal: true

module Emendate
  module Examples
    # Mixin module for Examples::Tester
    module DateTestable
      def expected_result
        return nil unless example.testable?

        example.rows
          .map { |row| row.send(name.to_sym) }
          .map { |val| val.start_with?("Date") ? instance_eval(val) : val }
          .map { |val| prep_expected(val) }
          .join("|")
      end

      def prep_expected(val)
        return val unless name == "date_certainty"

        val.split(";").sort.join(";")
      end

      def tested_result
        return nil unless example.testable?
        return "nilValue" if example.processed.result.dates.empty?

        case name
        when "date_certainty"
          example.processed.result.dates
            .map { |date| date.send(:qualifiers) }
            .map do |arr|
            arr.empty? ? "nilValue" : arr.map(&:for_test)
              .sort
              .join(";")
          end
            .join("|")

        else
          example.processed.result.dates
            .map { |date| date.send(name) }
            .map { |date| date.nil? ? "nilValue" : date }
            .join("|")
        end
      end
    end
  end
end
