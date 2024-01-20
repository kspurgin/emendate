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

      # @param sources [SegmentSets::SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:)
        cent = sources.first
        @century_type = get_century_type(cent)
        @set_type = get_set_type
        @literal = set_literal(cent)
        common_setup(binding)
      end

      # @return [:year]
      def granularity_level = :year

      # @return [Date]
      def earliest = Date.new(earliest_year, 1, 1)

      # @return [Date]
      def latest = Date.new(latest_year, 12, 31)

      # @return [String]
      def earliest_at_granularity = earliest.year.to_s

      # @return [String]
      def latest_at_granularity = latest.year.to_s

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
        base = (literal.to_s + "00").to_i
        (century_type == :name) ? base + 1 : base
      end
    end
  end
end
