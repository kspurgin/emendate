# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    # @todo Implement/test before/after a YearMonthDay
    class YearMonthDay
      include Datetypeable

      # @return [Integer]
      attr_reader :year
      # @return [Integer]
      attr_reader :month
      # @return [Integer]
      attr_reader :day
      # @return [:year_month_day]
      attr_reader :granularity_level

      # @param year [Integer]
      # @param month [Integer]
      # @param year [Integer]
      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:, year:, month:, day:)
        @year = year.to_i
        @month = month.to_i
        @day = day.to_i
        common_setup(binding)
        @granularity_level = :year_month_day
      end

      # @return [TrueClass]
      def qualifiable? = true

      # @return [TrueClass]
      def validatable? = true

      def literal = "#{year}"\
        "#{month.to_s.rjust(2, "0")}"\
        "#{day.to_s.rjust(2, "0")}"
        .to_i

      # @return [FalseClass] if no range switch is present, OR if
      #   range_switch is :before and the before_date_treatment
      #   setting is :point
      # @return [TrueClass] if range switch is :after, or range switch
      #   is :before with before_date_treatment :range
      def range?
        return false if range_switch == :before &&
          Emendate.options.before_date_treatment == :point
        return true if range_switch

        false
      end

      private

      def addable_token_types = %i[before after]

      def validate
        check_date_validity
        has_x_date_parts(3)
        has_one_part_of_type(:year)
        has_one_part_of_type(:month)
        has_one_part_of_type(:day)
      end

      def process_qualifiers
        add_source_segment_set_qualifiers
        begin_and_end_qualifiers.each { |qual| add_qualifier_as_whole(qual) }
        segment_qualifier_processing(:year, :month, :day)
      end

      def check_date_validity
        earliest
      rescue Date::Error
        fail Emendate::InvalidDateError,
          "#{self.class} with #{lexeme}"
      else
        self
      end

      def earliest_detail
        Date.new(year, month, day)
      end
      alias_method :latest_detail, :earliest_detail
    end
  end
end
