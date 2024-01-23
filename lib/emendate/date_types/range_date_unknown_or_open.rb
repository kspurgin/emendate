# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    # A date representing the beginning or end of a range, which is either
    # unknown or open (ongoing)
    class RangeDateUnknownOrOpen
      include Datetypeable

      attr_reader :granularity_level

      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      # @param category [:open, :unknown]
      # @param point [:start, :end]
      def initialize(sources:, category:, point:)
        common_setup(binding)
        @category = category
        @point = point
        @use_date = Emendate.options.send(
          :"open_unknown_#{point}_date"
        )
        @granularity_level = nil
      end

      def set_granularity(val) = (@granularity_level = val)

      # @return [Date] if point == :start
      # @return [NilClass] if point == :end
      def earliest
        use_date if point == :start
      end

      # @return [Date] if point == :end
      # @return [NilClass] if point == :start
      def latest
        use_date if point == :end
      end

      # @return [Integer]
      def literal = use_date.strftime("%Y%m%d").to_i

      # @return [FalseClass]
      def range? = false

      # Makes DateTypes behave as good members of a {SegmentSet}
      # @return [Symbol]
      def type = :"rangedate#{point}#{category}_date_type"

      private

      attr_reader :use_date, :category, :point
    end
  end
end
