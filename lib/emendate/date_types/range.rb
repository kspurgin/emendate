# frozen_string_literal: true

require_relative 'datetypeable'

module Emendate
  module DateTypes
    class Range
      include Datetypeable

      attr_reader :startdate, :enddate

      # @return [SegmentSets::SegmentSet
      attr_reader :sources

      # @param sources [SegmentSets::SegmentSet, Array<Segment>] The three
      #   segments included in the date type: start, range indicator, end
      def initialize(sources:)
        common_setup(binding)
        @startdate = sources[0]
        @enddate = sources[2]
      end

      # @return [Date]
      def earliest = startdate.earliest

      # @return [Date]
      def latest = enddate.latest

      # @return [TrueClass]
      def range? = true

      private

      attr_reader :startdate, :enddate
    end
  end
end
