# frozen_string_literal: true

require "emendate/segment/segment"
require "emendate/date_utils"

module Emendate
  class MonthAlpha < Segment
    include DateUtils

    private

    def default_literal
      result = [month_literal(lexeme), month_abbr_literal(lexeme)].compact
      raise Emendate::MonthLiteralError, lexeme if result.empty?

      result.first
    end

    def post_initialize(opts)
      super

      unless type == :month_alpha
        raise Emendate::TokenTypeError,
          "MonthAlpha must be created with type = :month_alpha"
      end

      @literal = default_literal if default_literal
    end
  end
end
