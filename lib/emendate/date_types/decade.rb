# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    class Decade
      include Datetypeable

      # @return [:plural, :uncertainty_digits]
      attr_reader :decade_type
      # @return [Integer]
      attr_reader :literal
      # @return [SegmentSet]
      attr_reader :sources
      # @return [:year]
      attr_reader :granularity_level

      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:)
        common_setup(binding)
        @decade_type = get_decade_type
        @literal = set_literal
        @granularity_level = :year
      end

      # @return [true]
      def range? = true

      private

      def get_decade_type
        case sources.source_type_string
        when /uncertainty_digits/
          :uncertainty_digits
        when /letter_s/
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

      def start_year
        (literal.to_s + "0").to_i
      end

      def earliest_detail
        year = case partial_indicator
        when nil
          start_year
        when :early
          start_year
        when :mid
          start_year + 4
        when :late
          start_year + 7
        end
        Date.new(year, 1, 1)
      end

      def latest_detail
        year = case partial_indicator
        when nil
          start_year + 9
        when :early
          start_year + 3
        when :mid
          start_year + 6
        when :late
          start_year + 9
        end
        Date.new(year, -1, -1)
      end
    end
  end
end
