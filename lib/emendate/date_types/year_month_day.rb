# frozen_string_literal: true

require_relative 'datetypeable'

module Emendate
  module DateTypes
    # @todo Implement/test before/after a YearMonthDay
    class YearMonthDay
      include Datetypeable

      # @param year [Integer]
      # @param month [Integer]
      # @param year [Integer]
      # @param sources [SegmentSets::SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:, year:, month:, day:)
        @year = year
        @month = month
        @day = day
        common_setup(binding)
      end

      def earliest
        Date.new(year, month, day)
      end

      def latest
        earliest
      end

      def literal = "#{year}"\
        "#{month.to_s.rjust(2, '0')}"\
        "#{day.to_s.rjust(2, '0')}"
        .to_i

      # @return [FalseClass] if no range switch is present, OR if
      #   range_switch is :before and the before_date_treatment
      #   setting is :point
      # @return [TrueClass] if range switch is :after, or range switch
      #   is :before with before_date_treatment :range
      def range?
        return false if range_switch == :before &&
                        Emendate.options.before_date_treatment == :point

        true if range_switch
      end

      attr_reader :year, :month, :day
    end
  end
end
