# frozen_string_literal: true

module Emendate
  module DateTypes

    class Range < Emendate::DateTypes::DateType
      attr_reader :startdate, :enddate, :indicator

      # Expect to be initialized with:
      #   sources: Emendate::SegmentSets::SegmentSet
      # Where the segment set has 3 segments (start, indicator, end)
      def initialize(**opts)
        super
        @startdate = sources[0]
        @indicator = sources[1]
        @enddate = sources[2]
      end

      def earliest
        return nil if startdate.nil?

        startdate.earliest
      end

      def latest
        return nil if enddate.nil?

        enddate.latest
      end

      def lexeme
        if earliest && latest
          "#{earliest.iso8601} - #{latest.iso8601}"
        elsif earliest
          "#{earliest.iso8601} -"
        elsif latest
          "- #{latest.iso8601}"
        end
      end

      def orig
        sources.orig_string
      end

      def range?
        true
      end
    end
  end
end
