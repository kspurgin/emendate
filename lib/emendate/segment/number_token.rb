# frozen_string_literal: true

require 'emendate/segment/token'
require 'emendate/date_utils'

module Emendate
  class NumberToken < Token
    include DateUtils

    attr_reader :digits

    def post_initialize(opts)
      unless type == :number
        raise Emendate::TokenTypeError.new('Number token must be created with type = :number')
      end

      unless lexeme.match?(/^\d+$/)
        raise Emendate::TokenLexemeError.new('Number token must be created with lexeme containing only numeric digits')
      end

      @digits = opts[:digits] || default_digits
      reset_type
    end

    def monthable?
      valid_month?(lexeme)
    end

    private

    def reset_type
      if allowed_digits?
        @type = digits <= 2 ? :number1or2 : "number#{digits}".to_sym
      else
        @type = :unknown
      end
    end

    def allowed_digits?
      [1, 2, 3, 4, 6, 8].include?(digits)
    end

    def default_digits
      lexeme.length
    end

    def default_literal
      lexeme.to_i
    end
  end
end
