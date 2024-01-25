# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    class Millennium
      include Datetypeable

      # @return [Integer]
      attr_reader :literal
      # @return [:plural, :uncertainty_digits]
      attr_reader :millennium_type
      # @return [:year]
      attr_reader :granularity_level

      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:)
        common_setup(binding)
        @millennium_type = get_millennium_type
        @literal = set_literal
        @granularity_level = :year
      end

      def range?
        true
      end

      private

      def get_millennium_type
        mill = sources.when_type(:millennium).first
        case mill.sources.date_parts.map(&:type).join(" ")
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

      def earliest_detail
        year = case partial_indicator
        when nil
          start_year
        when :early
          start_year
        when :mid
          start_year + 333
        when :late
          start_year + 666
        end
        Date.new(year, 1, 1)
      end

      def latest_detail
        year = case partial_indicator
        when nil
          start_year + 999
        when :early
          start_year + 333
        when :mid
          start_year + 666
        when :late
          start_year + 999
        end
        Date.new(year, -1, -1)
      end

      def start_year = (literal.to_s + "000").to_i
    end
  end
end
