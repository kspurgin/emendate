# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  
  class AlphaMonthConverter
  attr_reader :orig, :result
    include DateUtils
    def initialize(tokens:)
      @orig = tokens
      @result = Emendate::TokenSet.new
    end

    def convert
      orig.each do |t|
        case t.type
        when :month_alpha
          result << convert_month(t, month_number_lookup)
        when :month_abbr_alpha
          result << convert_month(t, month_abbr_number_lookup)
        else
          result << t
        end
      end
      result
    end

    private

    def convert_month(token, lookup)
      str = token.lexeme
      ind = lookup[str]
      Emendate::Token.new(lexeme: str,
                          type: :number_month,
                          literal: ind,
                          location: token.location)
    end
  end
end
