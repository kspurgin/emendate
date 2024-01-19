# frozen_string_literal: true

require_relative "datetypeable"
require_relative "six_digitable"

module Emendate
  module DateTypes
    class YearSeason
      include Datetypeable
      include SixDigitable

      NORTHERN_SEASONS = {
        spring: {start: [:year, 4, 1], end: [:year, 6, 30]},
        summer: {start: [:year, 7, 1], end: [:year, 9, 30]},
        fall: {start: [:year, 10, 1], end: [:year, 12, 31]},
        winter: {start: [:year, 1, 1], end: [:year, 3, 31]}
      }

      SOUTHERN_SEASONS = {
        spring: {start: [:year, 10, 1], end: [:year, 12, 31]},
        summer: {start: [:year, 1, 1], end: [:year, 3, 31]},
        fall: {start: [:year, 4, 1], end: [:year, 6, 30]},
        winter: {start: [:year, 7, 1], end: [:year, 9, 30]}
      }

      # A quarter (q) is defined as a 3-month period. A quadrimester (quad) is
      # defined as a 4-month period. A semestral is a 6-month period.
      OTHER_RANGES = {
        q1: {start: [:year, 1, 1], end: [:year, 3, 31]},
        q2: {start: [:year, 4, 1], end: [:year, 6, 30]},
        q3: {start: [:year, 7, 1], end: [:year, 9, 30]},
        q4: {start: [:year, 10, 1], end: [:year, 12, 31]},
        quad1: {start: [:year, 1, 1], end: [:year, 4, 30]},
        quad2: {start: [:year, 5, 1], end: [:year, 8, 31]},
        quad3: {start: [:year, 9, 1], end: [:year, 12, 31]},
        semestral1: {start: [:year, 1, 1], end: [:year, 6, 30]},
        semestral2: {start: [:year, 7, 1], end: [:year, 12, 31]}
      }

      # @param year [Integer]
      # @param season [Integer]
      # @param sources [SegmentSets::SegmentSet, Array<Segment>] Segments
      #   included in the date type
      # @param include_prev_year [Boolean] Used for values like
      #   "Winter 2019-2020", to cause the earliest date to include the end of
      #   2019
      def initialize(sources:, year:, season:, include_prev_year: false)
        common_setup(binding)
        @year = year
        @season = season
        @include_prev_year = include_prev_year
        @seasons = self.class.const_get(
          "#{Emendate.config.options.hemisphere}_seasons".upcase.to_sym
        )
      end

      # @return [TrueClass]
      def qualifiable? = true

      # @return [TrueClass]
      def validatable? = true

      def earliest
        return get_date(:start) unless include_prev_year

        Date.new(year - 1, 12, 1)
      end

      def latest
        get_date(:end)
      end

      def earliest_at_granularity
        "#{earliest.year}-#{earliest.month.to_s.rjust(2, "0")}"
      end

      def latest_at_granularity
        "#{latest.year}-#{latest.month.to_s.rjust(2, "0")}"
      end

      def range?
        !(partial_indicator.nil? && range_switch.nil?)
      end

      private

      attr_reader :year, :season, :seasons, :include_prev_year

      def validate
        has_x_date_parts(2)
        has_one_part_of_type(:year)
        has_one_part_of_type(:season)
      end

      def process_qualifiers
        add_source_segment_set_qualifiers
        begin_and_end_qualifiers.each { |qual| add_qualifier_as_whole(qual) }
        process_directional_qualifiers(:year, :season)
        process_single_segment_qualifiers
      end

      # @param type [:start, :end]
      def get_date(type)
        recipe = {
          21 => seasons.dig(:spring, type),
          22 => seasons.dig(:summer, type),
          23 => seasons.dig(:fall, type),
          24 => seasons.dig(:winter, type),

          25 => NORTHERN_SEASONS.dig(:spring, type),
          26 => NORTHERN_SEASONS.dig(:summer, type),
          27 => NORTHERN_SEASONS.dig(:fall, type),
          28 => NORTHERN_SEASONS.dig(:winter, type),

          29 => SOUTHERN_SEASONS.dig(:spring, type),
          30 => SOUTHERN_SEASONS.dig(:summer, type),
          31 => SOUTHERN_SEASONS.dig(:fall, type),
          32 => SOUTHERN_SEASONS.dig(:winter, type),

          33 => OTHER_RANGES.dig(:q1, type),
          34 => OTHER_RANGES.dig(:q2, type),
          35 => OTHER_RANGES.dig(:q3, type),
          36 => OTHER_RANGES.dig(:q4, type),
          37 => OTHER_RANGES.dig(:quad1, type),
          38 => OTHER_RANGES.dig(:quad2, type),
          39 => OTHER_RANGES.dig(:quad3, type),
          40 => OTHER_RANGES.dig(:semestral1, type),
          41 => OTHER_RANGES.dig(:semestral2, type)
        }.fetch(season)

        yr = case recipe[0]
        when :year
          year
        when :prev
          year - 1
        when :next
          year + 1
        end
        Date.new(yr, recipe[1], recipe[2])
      end
    end
  end
end
