# frozen_string_literal: true

require 'emendate/date_utils'
require 'emendate/result_editable'
require 'emendate/segment/derived_token'

module Emendate

  class AlphaMonthConverter
    attr_reader :result

    include DateUtils
    include ResultEditable
    
    def initialize(tokens:)
      @result = Emendate::SegmentSets::TokenSet.new.copy(tokens)
    end

    def convert
      result.each do |t|
        case t.type
        when :month_alpha
          replace_x_with_new(x: t, new: convert_month(t))
        when :month_abbr_alpha
          replace_x_with_new(x: t, new: convert_month(t))
        when :season
          replace_x_with_new(x: t, new: season_token_with_literal(t))
        else
          next
        end
      end
      result
    end

    private

    def convert_month(token)
      Emendate::DatePart.new(type: :month,
                             lexeme: token.lexeme,
                             literal: token.literal,
                             source_tokens: [token])
    end

    def get_season_literal(token)
      lookup = {
        'spring' => 21,
        'summer' => 22,
        'autumn' => 23,
        'fall' => 23,
        'winter' => 24
      }

      lookup[token.lexeme.downcase]
    end
    
    def season_token_with_literal(token)
      literal = get_season_literal(token)
      Emendate::DatePart.new(type: :season,
                             lexeme: token.lexeme,
                             literal: literal,
                             source_tokens: [token])
    end
  end
end
