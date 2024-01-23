# frozen_string_literal: true

require_relative "datetypeable"
require_relative "year_month_or_seasonable"

module Emendate
  module DateTypes
    # @todo Add earliest/latest at granularity
    class YearMonth
      include Datetypeable
      include YearMonthOrSeasonable

      # @return [:year_month]
      attr_reader :granularity_level

      # @param year [Integer]
      # @param month [Integer]
      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:, year:, month:)
        @year = year
        @month = month
        common_setup(binding)
        @granularity_level = :year_month
      end

      # @return [TrueClass]
      def qualifiable? = true

      # @return [TrueClass]
      def validatable? = true

      # @return [Date]
      def earliest = Date.new(year, month, 1)

      # @return [Date]
      def latest = Date.new(year, month, -1)

      # @return [FalseClass] if no partial indicator or range switch is present,
      #   OR if range_switch is :before and the before_date_treatment setting
      #   is :point
      # @return [TrueClass] if partial indicator is set, range switch is
      #   :after, or range switch is :before with before_date_treatment :range
      def range?
        return false if range_switch == :before &&
          Emendate.options.before_date_treatment == :point

        true if partial_indicator || range_switch
      end

      private

      attr_reader :year, :month

      def validate
        has_x_date_parts(2)
        has_one_part_of_type(:year)
        has_one_part_of_type(:month)
      end

      def process_qualifiers
        add_source_segment_set_qualifiers
        begin_and_end_qualifiers.each { |qual| add_qualifier_as_whole(qual) }
        segment_qualifier_processing(:year, :month)
      end
    end
  end
end
