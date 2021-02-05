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

    class UntaggableDatePatternError < StandardError
      attr_reader :date_parts, :reason
      def initialize(date_parts, reason)
        @date_parts = date_parts
        @reason = reason
        msg = "value: #{date_parts.map(&:lexeme).join}; reason: #{reason}"
        super(msg)
      end
    end
    
    attr_reader :orig, :options
    attr_accessor :result, :taggable
    include DateUtils
    def initialize(tokens:, options: {})
      @orig = tokens
      @result = Emendate::MixedSet.new
      orig.each{ |t| result << t }
      @taggable = true
      @options = options
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
      # this needs to happen before...
      when /.*number1or2 hyphen number1or2 hyphen number1or2.*/
        :tag_numeric_month_day_short_year
      # ...this
      when /.*number1or2 hyphen number1or2 hyphen year.*/
        :tag_numeric_month_day_year
      when /.*year hyphen number1or2 hyphen number1or2.*/
        :tag_year_numeric_month_day
      when /.*year hyphen number1or2.*/
        :tag_year_plus_numeric_month_or_season
      end
    end

    def full_match_tagger
      case result.type_string
      when /^year hyphen year$/
        :hyphen_to_range_indicator
      end
    end

    # types = Array with 2 Segment.type symbols
    # category = String that gets prepended to "date_part" to call DatePart building method 
    def collapse_pair(types_to_collapse, target_type)
      sources = result.extract(*types_to_collapse).segments
      replace_multi_with_date_part_type(sources: sources, date_part_type: target_type)
    end

    def hyphen_to_range_indicator
      result.each do |s|
        next unless s.type == :hyphen
        ri = Emendate::Token.new(type: :range_indicator,
                                 lexeme: s.lexeme,
                                 literal: s.literal,
                                 location: s.location)
        replace_x_with_given_segment(x: s, segment: ri)
      end
    end

    def new_date_part(type, sources)
      Emendate::DatePart.new(type: type,
                             lexeme: sources.map(&:lexeme).join,
                             literal: sources[0].literal,
                             source_tokens: sources)
    end
    
    def replace_multi_with_date_part_type(sources:, date_part_type:)
      new_date_part = new_date_part(date_part_type, sources)
      x_ind = result.find_index(sources[0])
      result.insert(x_ind + 1, new_date_part)
      sources.each{ |x| result.delete(x) }
    end

    def replace_x_with_date_part_type(x:, date_part_type:)
      new_date_part = new_date_part(date_part_type, [x])
      x_ind = result.find_index(x)
      result.insert(x_ind + 1, new_date_part)
      result.delete(x)
    end

    def replace_x_with_given_segment(x:, segment:)
      x_ind = result.find_index(x)
      result.insert(x_ind + 1, segment)
      result.delete(x)
    end

    def tag_century_num
      collapse_pair(%i[number1or2 century], :century)
    end

    def tag_day_in_mdy
      m, d, y = result.extract(:month, :number1or2, :year).segments
      raise UntaggableDatePartError.new(d, 'invalid day value') unless valid_date?(y, m, d)
      replace_x_with_date_part_type(x: d, date_part_type: :day)
    end

    def tag_decade_s
      collapse_pair(%i[year letter_s], :decade)
    end

    def tag_decade_uncertainty_digits
      collapse_pair(%i[year uncertainty_digits], :decade)
    end
    
    def tag_months
      result.each do |t|
        next unless t.type == :number_month
        replace_x_with_date_part_type(x: t, date_part_type: :month)
      end
    end

    def tag_numeric_month_day_year
      n1, h1, n2, h2, y = result.extract(%i[number1or2 hyphen number1or2 hyphen year]).segments
      begin
        analyzer = Emendate::MonthDayAnalyzer.new(n1, n2, y, options.ambiguous_month_day)
      rescue Emendate::MonthDayAnalyzer::MonthDayError => e
        raise e
      else
        month, day = [analyzer.month, analyzer.day]
        replace_x_with_date_part_type(x: month, date_part_type: :month)
        replace_x_with_date_part_type(x: day, date_part_type: :day)
      end
      [h1, h2].each{ |h| result.delete(h) }
    end

    def tag_numeric_month_day_short_year
      n1, h1, n2, h2, n3 = result.extract(%i[number1or2 hyphen number1or2 hyphen number1or2]).segments
      year = Emendate::ShortYearHandler.new(n3, options).result
      replace_x_with_given_segment(x: n3, segment: year)
      [h1, h2].each{ |h| result.delete(h) }
    end

    def tag_year_numeric_month_day
      y, h1, m, h2, d = result.extract(%i[year hyphen number1or2 hyphen number1or2]).segments
      [h1, h2].each{ |h| result.delete(h) }
      raise UntaggableDatePatternError.new([y, h1, m, h2, d], 'returns invalid date') unless valid_date?(y, m, d)

      replace_x_with_date_part_type(x: m, date_part_type: :month)
      replace_x_with_date_part_type(x: d, date_part_type: :day)
    end
    
    def tag_year_plus_numeric_month_or_season
      y, h, m = result.extract(%i[year hyphen number1or2]).segments
      analyzed = Emendate::MonthSeasonYearAnalyzer.new(m, y, options).result
      replace_x_with_given_segment(x: m, segment: analyzed)
      if analyzed.type == :year
        hyphen_to_range_indicator
      else
        result.delete(h)
      end
    end
    
    def tag_years
      result.each do |t|
        next unless t.type == :number4
        next unless valid_year?(t.lexeme)
        replace_x_with_date_part_type(x: t, date_part_type: :year)
      end
    end
  end
end
