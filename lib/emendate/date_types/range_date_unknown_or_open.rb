# frozen_string_literal: true

require_relative 'datetypeable'

module Emendate
  module DateTypes
    # A date representing the beginning or end of a range, which is either
    # unknown or open (ongoing)
    class RangeDateUnknownOrOpen
      include Datetypeable

      # @param sources [SegmentSets::SegmentSet] Segments included in
      #   the date type
      attr_reader :sources

      # @param sources [SegmentSets::SegmentSet, Array<Segment>] Segments
      #   included in the date type
      # @param category [:open, :unknown]
      # @param point [:start, :end]
      def initialize(sources:, category:, point:)
        common_setup(binding)
        @category = category
        @point = point
        @use_date = Emendate.options.send(
          "open_unknown_#{point}_date".to_sym
        )
      end

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

      # Returns `nil` because the actual granularity used should match the
      # granularity of the start/end date this one is paired with in a range
      # @return [NilClass]
      def earliest_at_granularity = nil

      # (see #earliest_at_granularity)
      def latest_at_granularity = nil

      # @return [Integer]
      def literal = use_date.strftime('%Y%m%d').to_i

      # @return [FalseClass]
      def range? = false

      # Makes DateTypes behave as good members of a {SegmentSets::SegmentSet}
      # @return [Symbol]
      def type = "rangedate#{point}#{category}_date_type".to_sym

      private

      attr_reader :use_date, :category, :point
    end
  end
end
