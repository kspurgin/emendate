# frozen_string_literal: true

module Emendate
  
  attr_reader :orig, :tokens
  class AlphaMonthConverter
    def initialize(tokens:)
      @orig = tokens
      @tokens = []
    end

    def convert
      @orig.each do |t|
        case t.type
        when :month_alpha
          @tokens << convert_month(t, Emendate::MONTH_LKUP)
        when :month_abbr_alpha
          @tokens << convert_month(t, Emendate::MONTH_ABBR_LKUP)
        else
          @tokens << t
        end
      end
      @tokens
    end

    private

    def convert_month(token, lookup)
      str = token.lexeme
      ind = lookup[str]
      Emendate::Token.new(lexeme: ind.to_s,
                          type: :number_month,
                          literal: ind,
                          location: token.location)
    end
  end
end
