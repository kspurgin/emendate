# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  class MonthDayAnalyzer
    class MonthDayError < StandardError
      def initialize(n1, n2, y)
        m = "Cannot determine valid month/date assignment for #{n1.lexeme}-#{n2.lexeme}-#{y.lexeme}"
        super(m)
      end
    end

    include DateUtils
    attr_reader :month, :day, :ambiguous

    def initialize(n1, n2, y, opt)
      @n1 = n1
      @n2 = n2
      @y = y
      @opt = opt
      @ambiguous = false
      analyze
    end

    private

    def analyze
      if !@n1.monthable? && @n2.monthable?
        month_day = [@n2, @n1]
      elsif @n1.monthable? && !@n2.monthable?
        month_day = [@n1, @n2]
      elsif @opt == :as_month_day
        @ambiguous = true
        month_day = [@n1, @n2]
      elsif @opt == :as_day_month
        @ambiguous = true
        month_day = [@n2, @n1]
      end

      if valid_date?(@y, month_day[0], month_day[1])
        @month = month_day[0]
        @day = month_day[1]
      else
        raise MonthDayError.new(@n1, @n2, @y)
      end
    end
  end
end
