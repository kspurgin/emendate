# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  class MonthDayAnalyzer
    class MonthDayError < Emendate::Error
      def initialize(n1, n2, y)
        m = "Cannot determine valid month/date assignment for #{n1.lexeme}-#{n2.lexeme}-#{y.lexeme}"
        super(m)
      end
    end

    include DateUtils

    attr_reader :month, :day, :ambiguous

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
      @ambiguous = false
    end

    def call
      analyze
      self
    end
    

    private

    attr_reader :n1, :n2, :y, :opt

    def analyze
      if !valid_month?(n1.lexeme) && valid_month?(n2.lexeme)
        @month = n2
        @day = n1
      elsif valid_month?(n1.lexeme) && !valid_month?(n2.lexeme)
        @month = n1
        @day = n2
      elsif opt == :as_month_day
        @ambiguous = true
        @month = n1
        @day = n2
      elsif opt == :as_day_month
        @ambiguous = true
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
