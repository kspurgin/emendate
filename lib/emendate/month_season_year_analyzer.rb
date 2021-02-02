# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  class MonthSeasonYearAnalyzer
    # class MonthDayError < StandardError
    #   def initialize(n1, n2, y)
    #     m = "Cannot determine valid month/date assignment for #{n1.lexeme}-#{n2.lexeme}-#{y.lexeme}"
    #     super(m)
    #   end
    # end
    
    include DateUtils
    attr_reader :n, :year, :options, :result

    def initialize(n, y, options)
      @n = n
      @year = y
      @options = options
      analyze
    end

    private

    def analyze
      if is_range?(year.lexeme, n.lexeme)
        @result = new_date_part(type: :year, lexeme: expand_year)
      elsif !possible_range?(year.lexeme, n.lexeme) && valid_month?(n.lexeme)
        @result = new_date_part(type: :month, lexeme: n.lexeme)
      elsif !possible_range?(year.lexeme, n.lexeme) && valid_season?(n.lexeme)
        @result = new_date_part(type: :season, lexeme: n.lexeme)
      elsif assume_year?
        @result = new_date_part(type: :year, lexeme: expand_year)
      elsif valid_month?(n.lexeme)
        @result = new_date_part(type: :month, lexeme: n.lexeme)
      elsif valid_season?(n.lexeme)
        @result = new_date_part(type: :season, lexeme: n.lexeme)
      end
    end

    def assume_year?
      options.ambiguous_month_year == :as_year ? true : false
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
  end
end
