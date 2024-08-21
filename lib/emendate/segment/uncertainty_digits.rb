# frozen_string_literal: true

require "emendate/segment/segment"
require "emendate/date_utils"

module Emendate
  class UncertaintyDigits < Segment
    include DateUtils

    # @param lexeme [String] of numerals reflecting how number
    #    originally appeared in string (with leading zeroes, etc.)
    def initialize(lexeme:, sources: nil)
      super(type: :uncertainty_digits, lexeme: lexeme, sources: sources)
      unless lexeme.match?(/^[\-xu?]+$/i)
        raise Emendate::TokenLexemeError,
          "UncertaintyDigits segments must be created with lexemes containing "\
          "only characters allowed as uncertainty digits"
      end

      @digits = lexeme.length
    end

    def to_s
      super
    end
    alias_method :inspect, :to_s

    private
  end
end
