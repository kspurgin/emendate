# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  class DatePartTagger
    class UntaggableDatePartError < StandardError
      attr_reader :date_part, :reason
      def initialize(date_part, reason)
        @date_part = date_part
        @reason = reason
        msg = "type: #{date_part.type}; value: #{date_part.lexeme}; reason: #{reason}"
        super(msg)
      end
    end
    
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
        :tag_decade_s
      when /.*year uncertainty_digits.*/
        :tag_decade_uncertainty_digits
      when /.*number1or2 century.*/
        :tag_century_num
      when /.*month number1or2 year.*/
        :tag_day_in_mdy
        # handling number1or2 hyphen number1or2 hyphen number1or2 should go here
        # just handle the year. the month/day will be handled below
        # we are assuming the year is last in this format
      when /.*number1or2 hyphen number1or2 hyphen year.*/
        # :tag_numeric_month_day
      end
    end

    def full_match_tagger
    end

    def tag_numeric_month_day
      n1, h1, n2, h2, y = result.extract(%i[number1or2 hyphen number1or2 hyphen year])
    end

    # types = Array with 2 Segment.type symbols
    # category = String that gets prepended to "date_part" to call DatePart building method 
    def collapse_pair(types, category)
      sources = result.extract(*types)
      pt1_i = result.find_index(sources[0])
      date_part = send("#{category}_date_part".to_sym, sources)
      result.insert(pt1_i, date_part)
      sources.each{ |s| result.delete_at(result.find_index(s)) }
    end

    def century_date_part(sources)
      Emendate::DatePart.new(type: :century,
                             lexeme: sources.map(&:lexeme).join,
                             literal: sources[0].literal,
                             source_tokens: source_set(sources))
    end

    def decade_date_part(sources)
      Emendate::DatePart.new(type: :decade,
                             lexeme: sources.map(&:lexeme).join,
                             literal: sources[0].literal,
                             source_tokens: source_set(sources))
    end

    def day_date_part(sources)
      Emendate::DatePart.new(type: :day,
                             lexeme: sources[0].lexeme,
                             literal: sources[0].literal,
                             source_tokens: source_set(sources))
    end
    
    def source_set(arr)
      s = Emendate::MixedSet.new
      arr.each{ |t| s << t }
    end

    def tag_century_num
      collapse_pair(%i[number1or2 century], 'century')
    end

    def tag_day_in_mdy
      m, d, y = result.extract(:month, :number1or2, :year)
      raise UntaggableDatePartError.new(d, 'invalid day value') unless valid_date?(y, m, d)
      d_ind = result.find_index(d)
      result.insert(d_ind + 1, day_date_part([d]))
      result.delete_at(d_ind)
    end

    def tag_decade_s
      collapse_pair(%i[year letter_s], 'decade')
    end

    def tag_decade_uncertainty_digits
      collapse_pair(%i[year uncertainty_digits], 'decade')
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

    def valid_date?(y, m, d)
      begin
        Date.new(y.literal, m.literal, d.literal)
      rescue Date::Error
        false
      else
        true
      end
    end
  end
end
