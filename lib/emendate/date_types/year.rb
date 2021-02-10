# frozen_string_literal: true

module Emendate
  module DateTypes
    class Year < Emendate::DateTypes::DateType
      attr_reader :year
      def initialize(**opts)
        super
        @year = opts[:year].is_a?(Integer) ? opts[:year] : opts[:year].to_i
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

      def earliest_by_partial
        case partial_indicator
        when nil
          Date.new(year, 1, 1)
        when 'early'
          Date.new(year, 1, 1)
        when 'mid'
          Date.new(year, 5, 1)
        when 'late'
          Date.new(year, 9, 1)
        end
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

      def latest_by_partial
        case partial_indicator
        when nil
          Date.new(year, 12, -1)
        when 'early'
          Date.new(year, 4, 30)
        when 'mid'
          Date.new(year, 8, 31)
        when 'late'
          Date.new(year, 12, 31)
        end
      end

      def lexeme
        year.to_s
      end

      def range?
        partial_indicator.nil? && range_switch.nil? ? false : true
      end
    end
  end
end
