# frozen_string_literal: true

module Emendate
  module NumberUtils
    extend self

    # note: can be valid day but not valid in the context of a given date (Feb 29 in a non-leap year)
    def valid_day?(str)
      int = str.to_i
      str.length <= 2 && int >= 1 && int <= 31
    end

    def valid_month?(str)
      int = str.to_i
      str.length <= 2 && int >= 1 && int <= 12
    end

    # EDTF season/quarter/semester indicators
    def valid_season?(str)
      int = str.to_i
      str.length == 2 && int >= 21 && int <= 41
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
