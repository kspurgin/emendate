# frozen_string_literal: true

module Emendate
  module DateTypes
    class Year < Emendate::DateTypes::DateType
      attr_reader :literal

      def initialize(**opts)
        super
        @literal = opts[:literal].is_a?(Integer) ? opts[:literal] : opts[:literal].to_i
      end

      def lexeme
        literal.to_s
      end

      def range?
        !(partial_indicator.nil? && range_switch.nil?)
      end

      def year
        literal
      end

      def earliest
        return earliest_by_partial if range_switch.nil?

        case range_switch
        when 'before'
          nil
        when 'after'
          latest_by_partial.next
        end
      end

      def earliest_at_granularity
        earliest.year.to_s
      end

      def latest
        return latest_by_partial if range_switch.nil?

        case range_switch
        when 'before'
          earliest_by_partial.prev_day
        when 'after'
          Date.today
        end
      end

      def latest_at_granularity
        latest.year.to_s
      end

      private
      
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
