# frozen_string_literal: true

module Emendate
  module DateTypes
    # Methods shared between YearMonth and YearSeason date types
    module YearMonthOrSeasonable
      def literal = "#{year}#{non_year_value.rjust(2, "0")}".to_i

      private

      def non_year_value
        return month.to_s if instance_variable_defined?(:@month)

        season.to_s
      end
    end
  end
end
