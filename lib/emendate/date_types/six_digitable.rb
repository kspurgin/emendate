# frozen_string_literal: true

module Emendate
  module DateTypes
    module SixDigitable
      def literal = "#{year}#{non_year_value.rjust(2, "0")}".to_i

      private

      def non_year_value
        return month.to_s if instance_variable_defined?(:@month)

        season.to_s
      end

      def set_up_from_year_month_or_integer(opts)
        if opts[:year] && opts[:month]
          @year = opts[:year].is_a?(Integer) ? opts[:year] : opts[:year].to_i
          # rubocop:todo Layout/LineLength
          @month = opts[:month].is_a?(Integer) ? opts[:month] : opts[:month].to_i
          # rubocop:enable Layout/LineLength
          @literal = "#{year}#{month.to_s.rjust(2, "0")}".to_i
        else
          # rubocop:todo Layout/LineLength
          @literal = opts[:literal].is_a?(Integer) ? opts[:literal] : opts[:literal].to_i
          # rubocop:enable Layout/LineLength
          parts = literal.to_s.match(/(\d{4})(.*)/)
          @year = parts[1].to_i
          @month = parts[2].to_i
        end
      end
    end
  end
end
