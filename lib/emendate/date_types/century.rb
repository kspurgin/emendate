# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    class Century
      include Datetypeable

      # @return [:name, :plural, :uncertainty_digits]
      attr_reader :century_type
      # @return [Integer]
      attr_reader :literal
      # @macro set_type_attr
      attr_reader :set_type
      # @return [:year]
      attr_reader :granularity_level

      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:)
        cent = sources.first
        @century_type = get_century_type(cent)
        @set_type = get_set_type
        @literal = set_literal(cent)
        common_setup(binding)
        @granularity_level = :year
      end

      # @return [true]
      def range? = true

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

      def get_century_type(datepart)
        if datepart.sources.types.include?(:letter_s)
          :plural
        elsif datepart.sources.types.include?(:uncertainty_digits)
          :uncertainty_digits
        else
          :name
        end
      end

      def get_set_type
        case century_type
        when :name then :inclusive
        when :plural then :inclusive
        when :uncertainty_digits then :alternate
        end
      end

      def earliest_detail
        year = case partial_indicator
        when nil
          start_year
        when :early
          start_year
        when :mid
          start_year + 33
        when :late
          start_year + 66
        end
        Date.new(year, 1, 1)
      end

      def latest_detail
        year = case partial_indicator
        when nil
          start_year + 99
        when :early
          start_year + 33
        when :mid
          start_year + 66
        when :late
          start_year + 99
        end
        Date.new(year, -1, -1)
      end

      def start_year
        base = (literal.to_s + "00").to_i
        return base unless century_type == :name

        base + 1
      end
    end
  end
end
