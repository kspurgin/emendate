# frozen_string_literal: true

require 'emendate/date_utils'

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

      tag_months if result.types.include?(:number_month)
      
      while taggable
        t = determine_tagger
        break if t.nil?
        send(t)
      end
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
      case result.type_string
      when /.*year letter_s.*/
        :tag_decade
      when /.*number1or2 century.*/
        :tag_century
      end
    end

    def full_match_tagger
    end

    def collapse_pair(types, category)
      pt1 = result.select{ |t| t.type == types[0] && result[result.find_index(t) + 1].type == types[1] }[0]
      pt1_i = result.find_index(pt1)
      pt2 = result[pt1_i + 1]
      sources = [pt1, pt2]
      date_part = send("#{category}_date_part".to_sym, sources)
      result.insert(pt1_i, date_part)
      sources.each{ |s| result.delete(s) }
    end

    def century_date_part(sources)
      Emendate::DatePart.new(type: :century,
                             lexeme: sources.map(&:lexeme).join,
                             literal: sources[0].literal,
                             source_tokens: sources)
    end

    def decade_date_part(sources)
      Emendate::DatePart.new(type: :decade,
                             lexeme: sources.map(&:lexeme).join,
                             literal: sources[0].literal,
                             source_tokens: sources)
    end
    
    def tag_century
      collapse_pair(%i[number1or2 century], 'century')
    end
    
    def tag_decade
      collapse_pair(%i[year letter_s], 'decade')
    end
    
    def tag_month(token)
      Emendate::DatePart.new(type: :month,
                             lexeme: token.lexeme,
                             literal: token.literal,
                             source_tokens: source_set([token]))
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

    def tag_years
      newresult = @result.map{ |t| t.type == :number4 ? tag_year(t) : t }
      @result = newresult
    end

    def source_set(arr)
      s = Emendate::TokenSet.new
      arr.each{ |t| s << t }
    end
  end
end
