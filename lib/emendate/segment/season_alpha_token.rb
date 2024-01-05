# frozen_string_literal: true

require 'emendate/segment/token'

module Emendate
  class SeasonAlphaToken < Token
    private

    LITERALS = {
      'spring' => 21,
      'summer' => 22,
      'fall' => 23,
      'autumn' => 23,
      'winter' => 24
    }

    def default_literal
      result = LITERALS[lexeme.downcase]
      raise Emendate::SeasonLiteralError, lexeme unless result

      result
    end

    def post_initialize(opts)
      super

      unless type == :season
        raise Emendate::TokenTypeError,
              'SeasonAlphaToken must be created with type = :season'
      end

      @literal = default_literal if default_literal
    end
  end
end
