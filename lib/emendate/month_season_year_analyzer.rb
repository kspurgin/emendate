# frozen_string_literal: true

require "emendate/date_utils"

module Emendate
  class MonthSeasonYearAnalyzer
    include DateUtils
    attr_reader :result, :type, :warnings

    class << self
      def call(...)
        new(...).call
      end
    end

    # @param year [Segment] representing known year
    # @param num [Segment] representing ambiguous number
    def initialize(year:, num:)
      @num = num
      @year = year
      @warnings = []
    end

    def call
      analyze
      @type = result.type
      self
    end

    private

    attr_reader :num, :year

    def analyze
      literal = num.literal

      if is_range?(year, num)
        type = :year
        literal = expanded_year
      elsif !maybe_range? && valid_month?(literal)
        type = :month
      elsif !maybe_range? && valid_season?(literal)
        type = :season
      elsif assume_year?
        type = :year
        literal = expanded_year
        warning = if maybe_range?
          "Ambiguous year + month/season/year treated as_year"
        else
          "Ambiguous year + month/season/year treated as_year, but this "\
            "creates invalid range"
        end
        @warnings << warning
      elsif valid_month?(literal)
        type = :month
        @warnings << "Ambiguous year + month/season/year treated as_month"
      elsif valid_season?(literal)
        type = :season
        @warnings << "Ambiguous year + month/season/year treated as_season"
      end

      @result = Emendate::Segment.new(
        type: type, literal: literal, lexeme: num.lexeme, sources: [num]
      )
    end

    def assume_year? = Emendate.options.ambiguous_month_year == :as_year

    def expanded_year = expand_shorter_digits(year, num)

    def maybe_range? = possible_range?(year, num)
  end
end
