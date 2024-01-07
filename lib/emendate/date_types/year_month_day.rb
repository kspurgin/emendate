# frozen_string_literal: true

module Emendate
  module DateTypes
    class YearMonthDay < Emendate::DateTypes::DateType
      attr_reader :literal, :year, :month, :day

      def initialize(**opts)
        super
        if opts[:year] && opts[:month] && opts[:day]
          @year = opts[:year].is_a?(Integer) ? opts[:year] : opts[:year].to_i
          @month = opts[:month].is_a?(Integer) ? opts[:month] : opts[:month].to_i
          @day = opts[:day].is_a?(Integer) ? opts[:day] : opts[:day].to_i
          @literal = "#{year}#{month.to_s.rjust(2, '0')}#{day.to_s.rjust(2, '0')}".to_i
        else
          @literal = opts[:literal].is_a?(Integer) ? opts[:literal] : opts[:literal].to_i
          parts = literal.to_s.match(/(\d{4})(\d{2})(\d{2})/)
          @year = parts[1].to_i
          @month = parts[2].to_i
          @day = parts[3].to_i
        end
      end

      def earliest
        Date.new(year, month, day)
      end

      def latest
        earliest
      end

      def range?
        false
      end
    end
  end
end
