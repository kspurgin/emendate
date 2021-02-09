# frozen_string_literal: true

module Emendate
  
  class UncertaintyDigitExploder
  attr_reader :result, :options
    def initialize(tokens:, options: {})
      @result = Emendate::TokenSet.new.copy(tokens)
      @options = options
    end

    def explode
      # while explodable?
      #   handle_explosion
      # end
      result
    end

    private

    def handle_explosion
      ud = uncertainty_digit_token
      ud_i = result.find_index(ud)
      prev = result[ud_i - 1]
      if prev.is_a?(Emendate::NumberToken)
        explode_and_insert(base: prev, ud: ud)
      else
        replace_with_unspecified_date_part(ud)
      end
    end

    def explode_and_insert(base:, ud:)
      exploded = explode_digits(base: base, ud: ud)
      ud_i = result.find_index(ud)
      ins_pt = ud_i + 1
      insert(ins_pt, exploded)
      [ud, base].each{ |t| result.delete(t) }
    end
    
    def explode_digits(base:, ud:)
      ud_l = ud.location.length
      oc = ["#{base.lexeme}#{'0' * ud_l}", "#{base.lexeme}#{'9' * ud_l}"]
      oct = oc.map{ |l| Emendate::NumberToken.new(type: :number, lexeme: l) }
      
      [oct[0], range_indicator, oct[1]]
    end
    
    def explodable?
      result.types.any?(:uncertainty_digits)
    end

    def insert(ins_pt, exploded)
      i = ins_pt
      exploded.each do |e|
        result.insert(i, e)
        i += 1
      end
    end

    def replace_with_unspecified_date_part(ud_token)
      ins_pt = result.find_index(ud_token) + 1
      result.insert(ins_pt, unspecified_date_part(ud_token))
      result.delete(ud_token)
    end
    
    def range_indicator
      Emendate::Token.new(type: :range_indicator,
                                 lexeme: '-',
                                 literal: '-',
                         #        location: s.location
                         )
    end

    def uncertainty_digit_token
      result.extract(%i[uncertainty_digits]).segments[0]
    end

    def unspecified_date_part(ud_token)
      Emendate::DatePart.new(type: :unspecified_date_part,
                             lexeme: ud_token.lexeme,
                             literal: ud_token.literal,
                             source_tokens: [ud_token])
                             
    end
  end
end
