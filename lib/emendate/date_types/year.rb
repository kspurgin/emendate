# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    class Year
      include Datetypeable

      # @return [:year]
      attr_reader :granularity_level

      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:)
        common_setup(binding)
        @orig_literal = first_numeric_literal
        @granularity_level = :year
      end

      # @return [Integer]
      def literal
        return adjusted_literal if era == :ce

        adjusted_literal * -1
      end

      # @return [true]
      def qualifiable? = true

      # @return [true]
      def validatable? = true

      # @return [Boolean] true if partial indicator or before/after range
      #   switch present
      def range?
        return false if range_switch == :before &&
          Emendate.options.before_date_treatment == :point
        return true if partial_indicator || range_switch

        false
      end

      private

      attr_reader :orig_literal

      def addable_token_types = %i[partial before after era_bce]

      def validate
        parts = sources.date_part_types
        if parts.length > 1
          raise Emendate::DateTypeCreationError, "#{self.class}: Expected "\
            "creation with 1 date_part. Received #{parts.length}: "\
            "#{parts.join(", ")}"
        end
      end

      def process_qualifiers
        add_source_segment_set_qualifiers
        sources.date_parts.first.qualifiers.each do |qual|
          add_qualifier(Emendate::Qualifier.new(
            type: qual.type,
            precision: :whole,
            lexeme: qual.lexeme
          ))
        end
      end

      def adjusted_literal
        if era == :bce && Emendate.options.bce_handling == :precise
          orig_literal - 1
        else
          orig_literal
        end
      end

      def earliest_detail
        case partial_indicator
        when nil
          Date.new(literal, 1, 1)
        when :early
          Date.new(literal, 1, 1)
        when :mid
          Date.new(literal, 5, 1)
        when :late
          Date.new(literal, 9, 1)
        end
      end

      def latest_detail
        case partial_indicator
        when nil
          Date.new(literal, 12, -1)
        when :early
          Date.new(literal, 4, 30)
        when :mid
          Date.new(literal, 8, 31)
        when :late
          Date.new(literal, 12, 31)
        end
      end
    end
  end
end
