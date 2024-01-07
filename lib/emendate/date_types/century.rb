# frozen_string_literal: true

require_relative 'datetypeable'

module Emendate
  module DateTypes
    class Century
      include Datetypeable

      # @return [:name, :plural, :uncertainty_digits]
      attr_reader :century_type
      # @return [Integer]
      attr_reader :literal
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
        cent = sources.first
        @century_type = set_type(cent)
        @literal = set_literal(cent)
        common_setup(binding)
      end

      def earliest
        Date.new(earliest_year, 1, 1)
      end

      def latest
        Date.new(latest_year, 12, 31)
      end

      def range?
        true
      end

      private

      def set_literal(datepart)
        case century_type
        when :name
          datepart.literal - 1
        when :plural
          datepart.literal.to_s[0..-3].to_i
        else
          datepart.literal
        end
      end

      def set_type(datepart)
        if datepart.sources.types.include?(:letter_s)
          :plural
        elsif datepart.sources.types.include?(:uncertainty_digits)
          :uncertainty_digits
        else
          :name
        end
      end

      def earliest_year
        year = start_year
        case partial_indicator
        when nil
          year
        when :early
          year
        when :mid
          year + 33
        when :late
          year + 66
        end
      end

      def latest_year
        year = start_year
        case partial_indicator
        when nil
          year + 99
        when :early
          year + 33
        when :mid
          year + 66
        when :late
          year + 99
        end
      end

      def start_year
        base = (literal.to_s + '00').to_i
        century_type == :name ? base + 1 : base
      end
    end
  end
end
