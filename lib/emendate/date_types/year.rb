# frozen_string_literal: true

module Emendate
  module DateTypes
    class Year < Emendate::DateTypes::DateType
      # @return [Integer]
      attr_reader :orig_literal
      # @return [:ce, :bce]
      attr_reader :era

      def initialize(**opts)
        super
        @orig_literal = opts[:literal].to_i
        @era = :ce
      end

      def bce
        @era = :bce
      end

      def lexeme
        year_string
      end

      def literal
        era == :bce ? (orig_literal - 1) * -1 : orig_literal
      end

      def range?
        return false if range_switch == 'before' &&
          Emendate.options.before_date_treatment == :point

        !(partial_indicator.nil? && range_switch.nil?)
      end

      def year
        literal
      end

      def earliest
        return earliest_by_partial unless range_switch

        case range_switch
        when 'before'
          earliest_for_before
        when 'after'
          latest_by_partial.next
        end
      end

      def earliest_at_granularity
        return year_string unless range_switch

        case range_switch
        when 'before'
          year_string(earliest.year)
        end
      end

      def latest
        return latest_by_partial unless range_switch

        case range_switch
        when 'before'
          earliest_by_partial.prev_day
        when 'after'
          Date.today
        end
      end

      def latest_at_granularity
        return year_string unless range_switch

        case range_switch
        when 'before'
          year_string(latest.year)
        end
      end

      private

      def year_string(val = literal)
        if val >= 0
          val.to_s.rjust(4, '0')
        else
          base = val.to_s
            .delete_prefix('-')
            .rjust(4, '0')
          "-#{base}"
        end
      end

      def earliest_by_partial
        case partial_indicator
        when nil
          Date.new(literal, 1, 1)
        when 'early'
          Date.new(literal, 1, 1)
        when 'mid'
          Date.new(literal, 5, 1)
        when 'late'
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
        when 'early'
          Date.new(literal, 4, 30)
        when 'mid'
          Date.new(literal, 8, 31)
        when 'late'
          Date.new(literal, 12, 31)
        end
      end
    end
  end
end
