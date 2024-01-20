# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    class Year
      include Datetypeable

      # @param sources [SegmentSets::SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:)
        common_setup(binding)
        @orig_literal = first_numeric_literal
      end

      # @return [Integer]
      def literal
        return adjusted_literal if era == :ce

        adjusted_literal * -1
      end

      # @return [:year]
      def granularity_level = :year

      # @return [true]
      def qualifiable? = true

      # @return [true]
      def validatable? = true

      # @return [Boolean] true if partial indicator or before/after range
      #   switch present
      def range?
        return false if range_switch == :before &&
          Emendate.options.before_date_treatment == :point

        true if partial_indicator || range_switch
      end

      # @return [Date]
      def earliest
        return earliest_by_partial unless range_switch

        case range_switch
        when :before
          earliest_for_before
        when :after
          latest_by_partial.next
        end
      end

      # @return [String]
      def earliest_at_granularity
        return year_string unless range_switch

        case range_switch
        when :before
          year_string(earliest.year)
        end
      end

      # @return [Date]
      def latest
        return latest_by_partial unless range_switch

        case range_switch
        when :before
          earliest_by_partial.prev_day
        when :after
          Date.today
        end
      end

      # @return [String]
      def latest_at_granularity
        return year_string unless range_switch

        case range_switch
        when :before
          year_string(latest.year)
        end
      end

      private

      attr_reader :orig_literal

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

      def year_string(val = literal)
        if val >= 0
          val.to_s.rjust(4, "0")
        else
          base = val.to_s
            .delete_prefix("-")
            .rjust(4, "0")
          "-#{base}"
        end
      end

      def earliest_by_partial
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

      def earliest_for_before
        if Emendate.options.before_date_treatment == :point
          latest
        else
          Emendate.options.open_unknown_start_date
        end
      end

      def latest_by_partial
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

      def addable_token_types = %i[partial before after era_bce]
    end
  end
end
