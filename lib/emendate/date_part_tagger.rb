# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  
  class DatePartTagger
  attr_reader :orig, :result
    include DateUtils
    def initialize(tokens:)
      @orig = tokens
      @result = Emendate::MixedSet.new
    end

    def tag
      tag_years
      result
    end

    private

    def tag_years
      orig.each do |t|
        result << ( t.type == :number4 ? tag_year(t) : t )
      end
    end

    def tag_year(token)
      return token unless valid_year?(token.lexeme)
      Emendate::DatePart.new(type: :year,
                             lexeme: token.lexeme,
                             literal: token.lexeme,
                             source_tokens: source_set([token]))
    end

    def source_set(arr)
      s = Emendate::TokenSet.new
      arr.each{ |t| s << t }
    end
  end
end
