# frozen_string_literal: true

module Emendate
  module DateTypes
    
    class YearMonthDay < Emendate::DateTypes::DateType
      attr_reader :month, :day
      def initialize(**opts)
        super
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
