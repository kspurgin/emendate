# frozen_string_literal: true

require_relative 'datetypeable'

module Emendate
  module DateTypes
    class Decade
      include Datetypeable

      # @return [:plural, :uncertainty_digits]
      attr_reader :decade_type
      # @return [Integer]
      attr_reader :literal
      # @return [SegmentSets::SegmentSet]
      attr_reader :sources

      # @param sources [SegmentSets::SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:)
        common_setup(binding)
        @decade_type = set_type
        @literal = set_literal
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

      def set_type
        case sources.source_type_string
        when /uncertainty_digits$/
          :uncertainty_digits
        when /letter_s$/
          :plural
        else
          raise Emendate::DecadeTypeError, lexeme
        end
      end

      def set_literal
        datepart = sources[0]
        case decade_type
        when :plural
          datepart.literal.to_s[0..-2].to_i
        else
          datepart.literal
        end
      end

      def decade_earliest_year
        (literal.to_s + '0').to_i
      end

      def earliest_year
        year = decade_earliest_year
        case partial_indicator
        when nil
          year
        when :early
          year
        when :mid
          year + 4
        when :late
          year + 7
        end
      end

      def latest_year
        year = decade_earliest_year
        case partial_indicator
        when nil
          year + 9
        when :early
          year + 3
        when :mid
          year + 6
        when :late
          year + 9
        end
      end
    end
  end
end
