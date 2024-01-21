# frozen_string_literal: true

require "emendate/segment/segment"
require "emendate/date_utils"

module Emendate
  # (see Segment#initialize)
  class MonthAlpha < Segment
    include DateUtils

    def initialize(...)
      super
      unless type == :month
        raise Emendate::TokenTypeError,
          "MonthAlpha must be created with type = :month"
      end

      @literal = default_literal if default_literal
    end

    private

    def default_literal
      result = [month_literal(lexeme), month_abbr_literal(lexeme)].compact
      raise Emendate::MonthLiteralError, lexeme if result.empty?

      result.first
    end
  end
end
