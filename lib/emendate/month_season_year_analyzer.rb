# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  class MonthSeasonYearAnalyzer
    include DateUtils
    attr_reader :result, :type, :warnings

    class << self
      def call(...)
        self.new(...).call
      end
    end

    def initialize(n, y)
      @n = n
      @year = y
      @warnings = []
    end

    def call
      analyze
      @type = result.type
      self
    end
    
    private

    attr_reader :n, :year
    
    def analyze
      if is_range?(year.lexeme, n.lexeme)
        @result = new_date_part(type: :year, lexeme: expand_year)
      elsif !maybe_range? && valid_month?(n.lexeme)
        @result = new_date_part(type: :month, lexeme: n.lexeme)
      elsif !maybe_range? && valid_season?(n.lexeme)
        @result = new_date_part(type: :season, lexeme: n.lexeme)
      elsif assume_year?
        @result = new_date_part(type: :year, lexeme: expand_year)
        if maybe_range?
          warning = 'Ambiguous month/year treated as year'
        else
          warning = 'Treating ambiguous month/year as year, but this creates invalid range'
        end
        @warnings << warning
      elsif valid_month?(n.lexeme)
        @result = new_date_part(type: :month, lexeme: n.lexeme)
        @warnings << 'Ambiguous month/year treated as month'
      elsif valid_season?(n.lexeme)
        @result = new_date_part(type: :season, lexeme: n.lexeme)
        @warnings << 'Ambiguous month/year treated as season'
      end
    end

    def assume_year?
      Emendate.options.ambiguous_month_year == :as_year
    end

    def new_date_part(type:, lexeme:)
      Emendate::DatePart.new(type: type,
                             lexeme: lexeme,
                             literal: lexeme.to_i,
                             source_tokens: [n])
    end

    def expand_year
      endpt = year.lexeme.length - n.lexeme.length - 1
      prefix = year.lexeme[0..endpt]
      "#{prefix}#{n.lexeme}"
    end

    def maybe_range?
      possible_range?(year.lexeme, n.lexeme)
    end
  end
end
