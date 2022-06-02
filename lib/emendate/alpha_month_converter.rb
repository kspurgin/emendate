# frozen_string_literal: true

require 'emendate/date_utils'
require 'emendate/result_editable'

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
          replace_x_with_new(x: t, new: convert_month(t, month_number_lookup))
        when :month_abbr_alpha
          replace_x_with_new(x: t, new: convert_month(t, month_abbr_number_lookup))
        else
          next
        end
      end
      result
    end

    private

    def convert_month(token, lookup)
      Emendate::DatePart.new(type: :month,
                             lexeme: token.lexeme,
                             literal: token.literal,
                             source_tokens: [token])
    end
  end
end
