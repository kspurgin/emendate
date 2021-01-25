# frozen_string_literal: true

module Emendate
  class DatePartTagger
    include NumberUtils

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
      if valid_day?(str) && valid_month?(str)
        type = :month_or_day
      elsif valid_day?(str)
        type = :day
      elsif valid_month?(str)
        type = :month
      elsif valid_season?(str)
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
