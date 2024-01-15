# frozen_string_literal: true

require "emendate/date_utils"
require "emendate/result_editable"

module Emendate
  class AlphaMonthConverter
    include DateUtils
    include Dry::Monads[:result]
    include ResultEditable

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = Emendate::SegmentSets::TokenSet.new.copy(tokens)
    end

    def call
      result.each do |t|
        case t.type
        when :month_alpha
          replace_x_with_new(x: t, new: convert_month(t))
        when :season
          replace_x_with_new(x: t, new: season_token_with_literal(t))
        else
          next
        end
      end
      Success(result)
    end

    private

    attr_reader :result

    # @todo need to set lexeme and literal here?
    def convert_month(token)
      Emendate::Segment.new(type: :month,
        lexeme: token.lexeme,
        literal: token.literal,
        sources: [token])
    end

    def get_season_literal(token)
      lookup = {
        "spring" => 21,
        "summer" => 22,
        "autumn" => 23,
        "fall" => 23,
        "winter" => 24
      }

      lookup[token.lexeme.downcase]
    end

    # @todo need to set lexeme here?
    def season_token_with_literal(token)
      literal = get_season_literal(token)
      Emendate::Segment.new(type: :season,
        lexeme: token.lexeme,
        literal: literal,
        sources: [token])
    end
  end
end
