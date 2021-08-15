# frozen_string_literal: true

require 'emendate/date_utils'
require 'emendate/result_editable'

module Emendate

  class AlphaMonthConverter
    attr_reader :result, :options

    include DateUtils
    include ResultEditable
    
    def initialize(tokens:, options: {})
      @result = Emendate::TokenSet.new.copy(tokens)
      @options = options
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
      str = token.lexeme.strip
      number = lookup[str]
      Emendate::DatePart.new(type: :month,
                             lexeme: str,
                             literal: number,
                             source_tokens: [token])
    end
  end
end
