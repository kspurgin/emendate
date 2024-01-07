# frozen_string_literal: true

require_relative 'datetypeable'

module Emendate
  module DateTypes
    class Millennium
      include Datetypeable

      # @return [Integer]
      attr_reader :literal
      # @return [:plural, :uncertainty_digits]
      attr_reader :millennium_type
      # @return [nil, :early, :mid, :late]
      attr_reader :partial_indicator
      # @return [SegmentSets::SegmentSet
      attr_reader :sources

      # @param sources [SegmentSets::SegmentSet, Array<Segment>] Segments
      #   included in the date type
      # @param partial_indicator [:early, :mid, :late] Changes the
      #   function of `earliest` and `latest` to reflect only part of the
      #   overall date part
      def initialize(sources:, partial_indicator: nil)
        common_setup(binding)
        @millennium_type = set_type
        @literal = set_literal
      end

      def earliest
        yr = "#{literal}000".to_i
        Date.new(yr, 1, 1)
      end

      def latest
        yr = "#{literal}999".to_i
        Date.new(yr, 12, 31)
      end

      def range?
        true
      end

      private

      def set_type
        case sources.source_type_string
        when /uncertainty_digits$/
          :uncertainty_digits
        when /letter_s$/
          :plural
        else
          raise Emendate::MillenniumTypeError, lexeme
        end
      end

      def set_literal
        datepart = sources[0]
        case millennium_type
        when :plural
          datepart.literal.to_s[0..-4].to_i
        else
          datepart.literal
        end
      end
    end
  end
end
