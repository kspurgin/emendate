# frozen_string_literal: true

require_relative './date_type'
require_relative './six_digitable'

module Emendate
  module DateTypes
    # uses :month to be behaviorally interchangeable with YearMonth date type
    class YearSeason < Emendate::DateTypes::DateType
      include SixDigitable

      attr_reader :literal, :year, :month, :include_prev_year

      # @option (see DateType#initialize)
      # @option opts [Integer] :year (nil) Literal of year source segment
      # @option opts [Integer] :month (nil) Literal of season source
      #   segment. Called month for consistency with {YearMonth} date
      #   type.
      # @option opts [Boolean] :include_prev_year (nil) Used for values like
      #   "Winter 2019-2020", to cause the earliest date to include the end of
      #   2019
      # @option opts [Integer] :literal (nil) Six digit YYYYSS literal to be
      #   parsed into a YearSeason
      def initialize(**opts)
        super
        @include_prev_year = opts[:include_prev_year]
        set_up_from_year_month_or_integer(opts)
      end

      def earliest
        return lookup_start_date unless include_prev_year

        Date.new(year - 1, 12, 1)
      end

      def latest
        lookup_end_date
      end

      def lexeme
        return literal.to_s if sources.empty?

        sources.segments.map(&:lexeme).join('')
      end

      def earliest_at_granularity
        "#{earliest.year}-#{earliest.month.to_s.rjust(2, '0')}"
      end

      def latest_at_granularity
        "#{latest.year}-#{latest.month.to_s.rjust(2, '0')}"
      end

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
          24 => Date.new(year, 1, 1),

          25 => Date.new(year, 4, 1),
          26 => Date.new(year, 7, 1),
          27 => Date.new(year, 10, 1),
          28 => Date.new(year, 1, 1),

          29 => Date.new(year, 10, 1),
          30 => Date.new(year, 1, 1),
          31 => Date.new(year, 4, 1),
          32 => Date.new(year, 7, 1),

          33 => Date.new(year, 1, 1),
          34 => Date.new(year, 4, 1),
          35 => Date.new(year, 7, 1),
          36 => Date.new(year, 10, 1),
          37 => Date.new(year, 1, 1),
          38 => Date.new(year, 5, 1),
          39 => Date.new(year, 9, 1),
          40 => Date.new(year, 1, 1),
          41 => Date.new(year, 7, 1)
        }.fetch(month)
      end

      def lookup_end_date
        {
          21 => Date.new(year, 6, 30),
          22 => Date.new(year, 9, 30),
          23 => Date.new(year, 12, 31),
          24 => Date.new(year, 3, 31),

          25 => Date.new(year, 6, 30),
          26 => Date.new(year, 9, 30),
          27 => Date.new(year, 12, 31),
          28 => Date.new(year, 3, 31),

          29 => Date.new(year, 12, 31),
          30 => Date.new(year, 3, 31),
          31 => Date.new(year, 6, 30),
          32 => Date.new(year, 9, 30),

          33 => Date.new(year, 3, 31),
          34 => Date.new(year, 6, 30),
          35 => Date.new(year, 9, 30),
          36 => Date.new(year, 12, 31),
          37 => Date.new(year, 4, 30),
          38 => Date.new(year, 8, 31),
          39 => Date.new(year, 12, 31),
          40 => Date.new(year, 6, 30),
          41 => Date.new(year, 12, 31)
        }.fetch(month)
      end
    end
  end
end
