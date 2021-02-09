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
    end
  end
end
