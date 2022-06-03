# frozen_string_literal: true

module Emendate
  module NumberUtils
    extend self

    def max_season
      return 24 if Emendate.options.max_month_number_handling == :edtf_level_1
      return 41 if Emendate.options.max_month_number_handling == :edtf_level_2
    end

    def min_season
      return 21 unless Emendate.options.max_month_number_handling == :months
    end

    # note: can be valid day but not valid in the context of a given date (Feb 29 in a non-leap year)
    def valid_day?(str)
      int = str.to_i
      str.length <= 2 && int >= 1 && int <= 31
    end

    def valid_month?(str)
      return false if str.length > 2
      
      int = str.to_i
      return false if int == 0
      return false if int > 12

      true
    end

    # EDTF season/quarter/semester indicators
    def valid_season?(str)
      return false if Emendate.options.max_month_number_handling == :months
      
      int = str.to_i
      return false if int < min_season
      return false if int > max_season

      true
    end

    def valid_year?(str)
      str = str.to_s unless str.is_a?(String)
      str.length <= 4 && str.to_i <= DateTime.now.year
    end

    def valid_month_or_season?(str)
      ( valid_month?(str) || valid_season?(str) )
    end
  end
end
