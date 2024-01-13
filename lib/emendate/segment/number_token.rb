# frozen_string_literal: true

require "emendate/segment/token"
require "emendate/date_utils"

module Emendate
  class NumberToken < Token
    include DateUtils

    attr_reader :digits

    private

    # allowable length of number in digits
    def allowed_digits?
      [1, 2, 3, 4, 6, 8].include?(digits)
    end

    def default_digits
      lexeme.length
    end

    def default_literal
      lexeme.to_i
    end

    # @todo Does opts[:digits] ever get passed in?
    def post_initialize(opts)
      super

      unless lexeme.match?(/^\d+$/)
        raise Emendate::TokenLexemeError,
          "Number token must be created with lexeme containing only numeric "\
          "digits"
      end

      @digits = opts[:digits] || default_digits
      reset_type
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
