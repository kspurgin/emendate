# frozen_string_literal: true

module Emendate
  module DateTypes

    class YearMonth < Emendate::DateTypes::DateType
      attr_reader :literal, :year, :month

      def initialize(**opts)
        super
        if opts[:year] && opts[:month]
          @year = opts[:year].is_a?(Integer) ? opts[:year] : opts[:year].to_i
          @month = opts[:month].is_a?(Integer) ? opts[:month] : opts[:month].to_i
          @literal = "#{year}#{month.to_s.rjust(2, '0')}".to_i
        else
          @literal = opts[:literal].is_a?(Integer) ? opts[:literal] : opts[:literal].to_i
          parts = literal.to_s.match(/(\d{4})(.*)/)
          @year = parts[1].to_i
          @month = parts[2].to_i
        end
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
        !(partial_indicator.nil? && range_switch.nil?)
      end
    end
  end
end
