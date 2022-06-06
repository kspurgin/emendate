# frozen_string_literal: true

require_relative './date_type'
require_relative './six_digitable'

module Emendate
  module DateTypes
    class YearMonth < Emendate::DateTypes::DateType
      include SixDigitable

      attr_reader :literal, :year, :month

      def initialize(**opts)
        super
        set_up_from_year_month_or_integer(opts)
      end

      def earliest
        Date.new(year, month, 1)
      end

      def latest
        Date.new(year, month, -1)
      end

      def lexeme
        "#{year}-#{month.to_s.rjust(2, '0')}"
      end

      def range?
        !(partial_indicator.nil? && range_switch.nil?)
      end
    end
  end
end
