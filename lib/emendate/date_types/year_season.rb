# frozen_string_literal: true

require_relative './date_type'
require_relative './six_digitable'

module Emendate
  module DateTypes
    # uses :month to be behaviorally interchangeable with YearMonth date type
    class YearSeason < Emendate::DateTypes::DateType
      include SixDigitable

      attr_reader :literal, :year, :month

      # Expect to be initialized with:
      #   sources: Emendate::SegmentSets::SegmentSet
      def initialize(**opts)
        super
        set_up_from_year_month_or_integer(opts)
      end

      def earliest
        lookup_start_date
      end

      def latest
        lookup_end_date
      end

      def lexeme
        "#{year}-#{month.to_s.rjust(2, '0')}"
      end
      alias_method :earliest_at_granularity, :lexeme
      alias_method :latest_at_granularity, :lexeme

      def range?
        !(partial_indicator.nil? && range_switch.nil?)
      end

      def season
        month
      end

      private

      def lookup_start_date
        {
          21 => Date.new(year, 4, 1),
          22 => Date.new(year, 7, 1),
          23 => Date.new(year, 10, 1),
          24 => Date.new(year, 1, 1)
        }.fetch(month)
      end

      def lookup_end_date
        {
          21 => Date.new(year, 6, 30),
          22 => Date.new(year, 9, 30),
          23 => Date.new(year, 12, 31),
          24 => Date.new(year, 3, 31)
        }.fetch(month)
      end

    end
  end
end
