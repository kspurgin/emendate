# frozen_string_literal: true

require 'emendate/date_utils'

# todo - get rid of hacky fix_result_type
# This is the fastest way I can get this working initially. I think the problem is calling map on a SegmentSet
#  returns an array instead of a SegmentSet.
# Need to look into how to use forwardable or some other technique to make this work better
module Emendate
  class DatePartTagger
    attr_reader :orig
    attr_accessor :result, :taggable
    include DateUtils
    def initialize(tokens:)
      @orig = tokens
      @result = Emendate::MixedSet.new
      orig.each{ |t| result << t }
      @taggable = true
    end

    def tag
      tag_years if orig.types.include?(:number4)
      fix_result_type

      tag_months if result.types.include?(:number_month)
      fix_result_type
      
      while taggable
        t = determine_tagger
        break if t.nil?
        send(t)
        fix_result_type
      end
      fix_result_type
      result
    end

    private

    def determine_tagger
      t = partial_match_tagger
      return t unless t.nil?

      t = full_match_tagger
      taggable = false if t.nil?
      t
    end

    def partial_match_tagger
    end

    def full_match_tagger
    end
    
    def tag_years
      newresult = @result.map{ |t| t.type == :number4 ? tag_year(t) : t }
      @result = newresult
    end

    def tag_months
      newresult = @result.map{ |t| t.type == :number_month ? tag_month(t) : t }
      @result = newresult
    end

    def tag_year(token)
      return token unless valid_year?(token.lexeme)
      Emendate::DatePart.new(type: :year,
                             lexeme: token.lexeme,
                             literal: token.literal,
                             source_tokens: source_set([token]))
    end

    def tag_month(token)
      Emendate::DatePart.new(type: :month,
                             lexeme: token.lexeme,
                             literal: token.literal,
                             source_tokens: source_set([token]))
    end

    def source_set(arr)
      s = Emendate::TokenSet.new
      arr.each{ |t| s << t }
    end

    def fix_result_type
      final_result = Emendate::MixedSet.new
      @result.each{ |t| final_result << t }
      @result = final_result
    end
  end
end
