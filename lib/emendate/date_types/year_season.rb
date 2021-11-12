# frozen_string_literal: true

module Emendate
  module DateTypes

    class YearSeason < Emendate::DateTypes::DateType
      attr_reader :season

      def initialize(**opts)
        super
        @season = opts[:month].is_a?(Integer) ? opts[:month] : opts[:month].to_i
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
        true
      end
    end
  end
end