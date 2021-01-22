# frozen_string_literal: true

module Emendate
  module NumberUtils
    extend self

    # note: can be valid day but not valid in the context of a given date (Feb 29 in a non-leap year)
    def valid_day?(str)
      int = str.to_i
      str.length <= 2 && int >= 1 && int <= 31 ? true : false
    end

    def valid_month?(str)
      int = str.to_i
      str.length <= 2 && int >= 1 && int <= 12 ? true : false
    end

    # EDTF season/quarter/semester indicators
    def valid_season?(str)
      int = str.to_i
      str.length == 2 && int >= 21 && int <= 41 ? true : false
    end

    def valid_year?(str)
      str.length <= 4 && str.to_i <= DateTime.now.year ? true : false
    end

    def valid_month_or_season?(str)
      ( valid_month?(str) || valid_season?(str) ) ? true : false
    end
  end
end
