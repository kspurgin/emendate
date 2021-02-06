# frozen_string_literal: true

module Emendate
  module DateTypes
    
    class YearMonthDay < Emendate::DateTypes::DateType
      attr_reader :year, :month, :day
      def initialize(**opts)
        super
        @year = opts[:year].is_a?(Integer) ? opts[:year] : opts[:year].to_i
        @month = opts[:month].is_a?(Integer) ? opts[:month] : opts[:month].to_i
        @day = opts[:day].is_a?(Integer) ? opts[:day] : opts[:day].to_i
      end

      def earliest
        Date.new(year, month, day)
      end

      def latest
        earliest
      end

      def lexeme
        "#{year}-#{month.to_s.rjust(2, '0')}-#{day.to_s.rjust(2, '0')}"
      end
    end
  end
end
