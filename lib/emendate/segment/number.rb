# frozen_string_literal: true

require "emendate/segment/segment"
require "emendate/date_utils"

module Emendate
  class Number < Segment
    include DateUtils

    # @param lexeme [String] of numerals reflecting how number
    #    originally appeared in string (with leading zeroes, etc.)
    def initialize(lexeme:)
      super(type: :number, lexeme: lexeme)
      unless lexeme.match?(/^\d+$/)
        raise Emendate::TokenLexemeError,
          "Number token must be created with lexeme containing only numeric "\
          "digits"
      end

      @digits = lexeme.length
      @literal = lexeme.to_i
      reset_type
    end

    # @return [TrueClass]
    def number? = true

    def to_s
      super
    end
    alias_method :inspect, :to_s

    private

    # allowable length of number in digits
    def allowed_digits?
      [1, 2, 3, 4, 6, 8].include?(digits)
    end

    def reset_type
      if zero?
        @type = :standalone_zero
        @literal = nil
      elsif allowed_digits?
        @type = (digits <= 2) ? :number1or2 : :"number#{digits}"
      else
        @type = :unknown
      end
    end

    def zero?
      digits == 1 && lexeme == "0"
    end
  end
end
