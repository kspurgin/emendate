# frozen_string_literal: true

require 'emendate/number_utils'

module Emendate
  module DateUtils
    include Emendate::NumberUtils
    extend self

    # returns 2010 for 2020-10; returns 1999 for 1998-9
    def expand_shorter_digits(year, digits)
      diff = year.length - digits.length - 1
      "#{year[0..diff]}#{digits}"
    end

    # returns true if it's a possible range and it can't be month/season
    def is_range?(year, digits)
      possible_range?(year, digits) && !valid_month_or_season?(digits) ? true : false
    end

    def month_abbr_literal(month)
      lookup = {}
      Date::ABBR_MONTHNAMES.compact.map(&:downcase).each_with_index{ |str, i| lookup[str] = i + 1 }
      lookup['sept'] = 9
      lookup[month.downcase.strip.delete_suffix('.')]
    end

    def month_literal(month)
      Date::MONTHNAMES.map{ |mth| mth.downcase if mth}.index(month.downcase)
    end

    # determines whether the number following a year could be the end of a range beginning with that year
    # 2020-10 -- false, the 10 has to be October
    # 2020-21 -- true, the 21 could indicate 2021 as end of range, OR this could mean Spring 2020
    def possible_range?(year, digits)
      expanded = expand_shorter_digits(year, digits)
      return false unless valid_year?(expanded)

      expanded.to_i > year.to_i
    end

    # pass in segments. This pulls out literals
    def valid_date?(yr, mth, day)
      begin
        Date.new(yr.literal, mth.literal, day.literal)
      rescue Date::Error
        valid_english_date?(yr, mth, day)
      else
        true
      end
    end

    def valid_english_date?(yr, mth, day)
      begin
        Date.new(yr.literal, mth.literal, day.literal, Date::ENGLAND)
      rescue Date::Error
        false
      else
        true
      end
    end
  end
end
