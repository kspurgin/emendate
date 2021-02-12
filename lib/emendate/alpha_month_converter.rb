# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  
  class AlphaMonthConverter
    attr_reader :result, :options
    include DateUtils
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

    def replace_x_with_new(x:, new:)
      ins_pt = result.find_index(x) + 1
      result.insert(ins_pt, new)
      result.delete(x)
    end
    
    def convert_month(token, lookup)
      str = token.lexeme
      number = lookup[str]
      Emendate::DatePart.new(type: :month,
                             lexeme: str,
                             literal: number,
                             source_tokens: [token])
    end
  end
end
