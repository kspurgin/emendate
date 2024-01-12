# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  class MonthSeasonYearAnalyzer
    include DateUtils
    attr_reader :result, :type, :warnings

    class << self
      def call(...)
        new(...).call
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
      if is_range?(year, n)
        @result = new_date_part(type: :year, literal: expand_year)
      elsif !maybe_range? && valid_month?(n.literal)
        @result = new_date_part(type: :month, literal: n.literal)
      elsif !maybe_range? && valid_season?(n.literal)
        @result = new_date_part(type: :season, literal: n.literal)
      elsif assume_year?
        @result = new_date_part(type: :year, literal: expand_year)
        warning = if maybe_range?
                    'Ambiguous year + month/season/year treated as_year'
                  else
                    'Ambiguous year + month/season/year treated as_year, but this creates invalid range'
                  end
        @warnings << warning
      elsif valid_month?(n.literal)
        @result = new_date_part(type: :month, literal: n.literal)
        @warnings << 'Ambiguous year + month/season/year treated as_month'
      elsif valid_season?(n.literal)
        @result = new_date_part(type: :season, literal: n.literal)
        @warnings << 'Ambiguous year + month/season/year treated as_season'
      end
    end

    def assume_year?
      Emendate.options.ambiguous_month_year == :as_year
    end

    def new_date_part(type:, literal:)
      Emendate::DatePart.new(type: type,
                             lexeme: n.lexeme,
                             literal: literal.to_i,
                             sources: [n])
    end

    def expand_year
      endpt = year.lexeme.length - n.lexeme.length - 1
      prefix = year.lexeme[0..endpt]
      "#{prefix}#{n.lexeme}"
    end

    def maybe_range?
      possible_range?(year, n)
    end
  end
end
