# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    class Range
      include Datetypeable

      attr_reader :startdate, :enddate

      # @return [SegmentSet
      attr_reader :sources

      attr_reader :granularity_level

      # @param sources [SegmentSet, Array<Segment>] The three
      #   segments included in the date type: start, range indicator, end
      def initialize(sources:)
        common_setup(binding)
        @startdate = sources[0]
        @enddate = sources[2]
        @granularity_level = set_granularity_level
      end

      # @return [Symbol]
      def start_granularity = granularity_level[0]

      # @return [Symbol]
      def end_granularity = granularity_level[1]

      # @return [true]
      def qualifiable? = true

      # @return [true]
      def validatable? = true

      # @return [Date]
      def earliest = startdate.earliest

      # @return [Date]
      def latest = enddate.latest

      # @return [Date]
      def earliest = startdate.earliest

      # @return [Date]
      def latest = enddate.latest

      # @return [true]
      def range? = true

      private

      # @return [Array<Symbol, Symbol>]
      def set_granularity_level
        sg = startdate.granularity_level
        eg = enddate.granularity_level
        if sg && eg
          [sg, eg]
        elsif sg
          enddate.set_granularity(sg)
          [sg, sg]
        elsif eg
          startdate.set_granularity(eg)
          [eg, eg]
        end
      end

      def validate
        parts = sources.date_part_types
        unless parts.length == 2
          raise Emendate::DateTypeCreationError, "#{self.class}: Expected "\
            "creation with 2 date_parts. Received #{parts.length}: "\
            "#{parts.join(", ")}"
        end
      end

      def process_qualifiers
        process_quals(sources[0], :start)
        process_quals(sources[2], :end)
      end

      def process_quals(seg, pos)
        seg.qualifiers.each do |qual|
          add_qualifier(Emendate::Qualifier.new(
            type: qual.type,
            precision: pos,
            lexeme: qual.lexeme
          ))
        end
      end
    end
  end
end
