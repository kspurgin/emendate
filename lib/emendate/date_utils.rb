# frozen_string_literal: true

module Emendate
  module DateUtils
    extend self

    # @param year [String] the known full year
    # @param digits [String] the following shorter digit string to be
    #   expanded
    # @return [String] the shorter digits, expanded to follow the pattern
    #   of the given `year` value. Examples: returns 2010 for 2020-10; returns
    #   1999 for 1998-9
    def expand_shorter_digits(year, digits)
      diff = year.length - digits.length - 1
      "#{year[0..diff]}#{digits}"
    end

    # @param year [String] the known full year
    # @param digits [String] the shorter digit segment following year
    # @return [Boolean] true if it's a possible range and it can't be a
    #   month/season
    def is_range?(year, digits)
      possible_range?(year, digits) && !valid_month_or_season?(digits) ? true : false
    end

    # @return [24] when max_month_number_handling == :edtf_level_1
    # @return [41] when max_month_number_handling == :edtf_level_2
    # @return [NilClass] when max_month_number_handling == :months
    def max_season
      return 24 if Emendate.options.max_month_number_handling == :edtf_level_1

      41 if Emendate.options.max_month_number_handling == :edtf_level_2
    end

    # @return [NilClass] when max_month_number_handling == :months
    # @return [21] otherwise
    def min_season
      21 unless Emendate.options.max_month_number_handling == :months
    end

    # @param month [String] month abbreviation
    # @return [Integer]
    def month_abbr_literal(month)
      lookup = {}
      Date::ABBR_MONTHNAMES.compact.map(&:downcase).each_with_index{ |str, i| lookup[str] = i + 1 }
      lookup['sept'] = 9
      lookup[month.downcase.strip.delete_suffix('.')]
    end

    # @param month [String] full month name
    # @return [Integer]
    def month_literal(month)
      Date::MONTHNAMES.map{ |mth| mth.downcase if mth }.index(month.downcase)
    end

    # determines whether the number following a year could be the end of a range beginning with that year
    # 2020-10 -- false, the 10 has to be October
    # 2020-21 -- true, the 21 could indicate 2021 as end of range, OR this could mean Spring 2020
    def possible_range?(year, digits)
      expanded = expand_shorter_digits(year.to_s, digits.to_s)
      return false unless valid_year?(expanded)

      expanded.to_i > year.to_i
    end

    # @param yr [Segment]
    # @param mth [Segment]
    # @param day [Segment]
    # @return [TrueClass] if segment literals can be converted to a valid date
    # @return [FalseClass] otherwise
    def valid_date?(yr, mth, day)
      Date.new(yr.literal, mth.literal, day.literal)
    rescue Date::Error
      valid_english_date?(yr, mth, day)
    else
      true
    end

    # @param int [Integer]
    # @return [TrueClass] if 1 to 31
    # @return [FalseClass] otherwise
    def valid_day?(int)
      raise StandardError, 'string passed instead of integer' unless int.is_a?(Integer)

      int >= 1 && int <= 31
    end

    # @param yr [Segment]
    # @param mth [Segment]
    # @param day [Segment]
    # @return [TrueClass] if segment literals can be converted to a valid
    #   English date
    # @return [FalseClass] otherwise
    def valid_english_date?(yr, mth, day)
      Date.new(yr.literal, mth.literal, day.literal, Date::ENGLAND)
    rescue Date::Error
      false
    else
      true
    end
    private :valid_english_date?

    # @param int [Integer]
    # @return [TrueClass] if 1 to 12
    # @return [FalseClass] otherwise
    def valid_month?(int)
      raise StandardError, 'string passed instead of integer' unless int.is_a?(Integer)

      int > 0 && int < 13
    end

    # @param int [Integer]
    # @return [TrueClass] if is {#valid_month?} or {#valid_season?}
    # @return [FalseClass] otherwise
    def valid_month_or_season?(int)
      raise StandardError, 'string passed instead of integer' unless int.is_a?(Integer)

      (valid_month?(int) || valid_season?(int))
    end

    # @param int [Integer]
    # @return [TrueClass] if is a valid EDTF season/quarter/semester indicator
    # @return [FalseClass] otherwise
    def valid_season?(int)
      raise StandardError, 'string passed instead of integer' unless int.is_a?(Integer)

      return false if Emendate.options.max_month_number_handling == :months

      int >= min_season && int <= max_season
    end

    # @todo Years shouldn't have to be fewer than 4 digits - check/fix this assumption
    def valid_year?(str)
      str = str.to_s unless str.is_a?(String)
      str.length <= 4
    end
  end
end
