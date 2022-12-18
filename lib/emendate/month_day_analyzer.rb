# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  class MonthDayAnalyzer
    include DateUtils

    attr_reader :month, :day, :warnings

    class << self
      def call(...)
        self.new(...).call
      end
    end

    def initialize(n1, n2, y)
      @n1 = n1
      @n2 = n2
      @y = y
      @opt = Emendate.options.ambiguous_month_day
      @warnings = []
    end

    def call
      analyze
      self
    end


    private

    attr_reader :n1, :n2, :y, :opt

    def add_warning
      @warnings << "Ambiguous month/day treated #{Emendate.options.ambiguous_month_day}"
    end

    def analyze
      if !valid_month?(n1.lexeme) && valid_month?(n2.lexeme)
        @month = n2
        @day = n1
      elsif valid_month?(n1.lexeme) && !valid_month?(n2.lexeme)
        @month = n1
        @day = n2
      elsif opt == :as_month_day
        add_warning
        @month = n1
        @day = n2
      elsif opt == :as_day_month
        add_warning
        @month = n2
        @day = n1
      end

      unless valid_date?(y, month, day)
        @month = nil
        @day = nil
        raise MonthDayError.new(n1, n2, y)
      end
    end
  end
end
