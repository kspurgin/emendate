# frozen_string_literal: true

module Emendate
  class DatePartTagger

    attr_reader :orig, :tokens

    def initialize(tokens:)
      @orig = tokens
      @tokens = []
    end

    def tag
      orig.each{ |t| analyze_token(t) }
      tokens
    end

    private

    def analyze_token(token)
      case token.type
      when :number1or2
        analyze_1_or_2_digit_number(token)
      else
        tokens << token
      end
    end

    def analyze_1_or_2_digit_number(token)
      str = token.lexeme
      if Emendate::NumberUtils.valid_day?(str) && Emendate::NumberUtils.valid_month?(str)
        type = :month_or_day
      elsif Emendate::NumberUtils.valid_day?(str)
        type = :day
      elsif Emendate::NumberUtils.valid_month?(str)
        type = :month
      elsif Emendate::NumberUtils.valid_season?(str)
        type = :season
      end

      if type.nil?
        tokens << token
      else
        tokens << Emendate::Token.new(type: type,
                                      lexeme: token.lexeme,
                                      literal: token.lexeme.to_i,
                                      location: token.location)
      end
    end
  end
end
