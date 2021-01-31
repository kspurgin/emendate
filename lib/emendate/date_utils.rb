# frozen_string_literal: true
require 'emendate/number_utils'

module Emendate
  module DateUtils
    include Emendate::NumberUtils
    extend self

    # returns true if digits after a year could be interpreted as (month OR season) OR range
    def ambiguous_post_year_value?(year, digits)
      possible_range?(year, digits) && valid_month_or_season?(digits) ? true : false
    end

    # returns 2010 for 2020-10; returns 1999 for 1998-9
    def expand_shorter_digits(year, digits)
      diff = year.length - digits.length - 1
      "#{year[0..diff]}#{digits}"
    end

    # returns true if it's a possible range and it can't be month/season
    def is_range?(year, digits)
      possible_range?(year, digits) && !valid_month_or_season?(digits) ? true : false
    end

    def month_number_lookup
      h = {}
      Date::MONTHNAMES.compact.map(&:downcase).each_with_index{ |str, i| h[str] = i + 1 }
      h
    end

    def month_abbr_number_lookup
      h = {}
      Date::ABBR_MONTHNAMES.compact.map(&:downcase).each_with_index{ |str, i| h[str] = i + 1 }
      h
    end
    
    # determines whether the number following a year could be the end of a range beginning with that year
    # 2020-10 -- false, the 10 has to be October
    # 2020-21 -- true, the 21 could indicate 2021 as end of range, OR this could mean Spring 2020
    def possible_range?(year, digits)
      expanded = expand_shorter_digits(year, digits)
      return false unless valid_year?(expanded)
      expanded.to_i > year.to_i ? true : false
    end

    def two_digit_year(yr)
      year = yr.is_a?(String) ? yr : yr.to_s
      max = year.length - 1
      min = max - 1
      year[min..max]
    end

    # pass in segments. This pulls out literals
    def valid_date?(y, m, d)
      begin
        Date.new(y.literal, m.literal, d.literal)
      rescue Date::Error
        valid_english_date?(y, m, d)
      else
        true
      end
    end

    def valid_english_date?(y, m, d)
      begin
        Date.new(y.literal, m.literal, d.literal, Date::ENGLAND)
      rescue Date::Error
        false
      else
        true
      end
    end
  end
end
