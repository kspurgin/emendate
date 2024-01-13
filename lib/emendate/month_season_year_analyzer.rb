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
      if is_range?(year, num)
        @result = new_date_part(type: :year, literal: expanded_year)
      elsif !maybe_range? && valid_month?(num.literal)
        @result = new_date_part(type: :month, literal: num.literal)
      elsif !maybe_range? && valid_season?(num.literal)
        @result = new_date_part(type: :season, literal: num.literal)
      elsif assume_year?
        @result = new_date_part(type: :year, literal: expanded_year)
        warning = if maybe_range?
          "Ambiguous year + month/season/year treated as_year"
        else
          # rubocop:todo Layout/LineLength
          "Ambiguous year + month/season/year treated as_year, but this creates invalid range"
          # rubocop:enable Layout/LineLength
        end
        @warnings << warning
      elsif valid_month?(num.literal)
        @result = new_date_part(type: :month, literal: num.literal)
        @warnings << "Ambiguous year + month/season/year treated as_month"
      elsif valid_season?(num.literal)
        @result = new_date_part(type: :season, literal: num.literal)
        @warnings << "Ambiguous year + month/season/year treated as_season"
      end
    end

    def assume_year?
      Emendate.options.ambiguous_month_year == :as_year
    end

    def new_date_part(type:, literal:)
      Emendate::DatePart.new(type: type,
        lexeme: num.lexeme,
        literal: literal.to_i,
        sources: [num])
    end

    def expanded_year
      expand_shorter_digits(year, num)
    end

    def maybe_range?
      possible_range?(year, num)
    end
  end
end
