# frozen_string_literal: true

module Emendate
  module DateTypes
    
    class YearMonth < Emendate::DateTypes::DateType
      attr_reader :year, :month
      def initialize(**opts)
        super
        @year = opts[:year].is_a?(Integer) ? opts[:year] : opts[:year].to_i
        @month = opts[:month].is_a?(Integer) ? opts[:month] : opts[:month].to_i
      end

      def earliest
        Date.new(year, month, 1)
      end

      def latest
        Date.new(year, month, -1)
      end

      def lexeme
        "#{year}-#{month.to_s.rjust(2, '0')}"
      end

      def range?
        partial_indicator.nil? && range_switch.nil? ? false : true
      end
    end
  end
end
