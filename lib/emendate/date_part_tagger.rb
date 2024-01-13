# frozen_string_literal: true

require "emendate/all_short_mdy_analyzer"
require "emendate/date_utils"
require "emendate/result_editable"

module Emendate
  class DatePartTagger
    include DateUtils
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)
    include ResultEditable

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = Emendate::SegmentSets::SegmentSet.new.copy(tokens)
      @taggable = true
    end

    def call
      _years_tagged = yield tag_years
      _tagged = yield tag

      Success(result)
    end

    private

    attr_reader :result, :taggable

    def tag
      while taggable
        t = determine_tagger
        break if t.nil?

        t.is_a?(Symbol) ? send(t) : send(t.shift, *t)
      end
    rescue Emendate::Error => e
      Failure(e)
    else
      Success()
    end

    def determine_tagger
      t = full_match_tagger
      return t unless t.nil?

      t = partial_match_tagger
      @taggable = false if t.nil?
      t
    end

    def full_match_tagger
      case result.type_string
      when /^number1or2 year$/
        :tag_numeric_month
      end
    end

    def partial_match_tagger
      case result.type_string
      when /.*year letter_s.*/
        :tag_pluralized_year
      when /.*uncertainty_digits.*/
        :tag_with_uncertainty_digits
      when /.*number1or2 century.*/
        :tag_century_num
      when /.*month number1or2 year.*/
        :tag_day_in_mdy
      when /.*season number1or2.*/
        :tag_year_in_season_short_year
      when /.*month number1or2.*/
        :tag_year_in_month_short_year
        # this needs to happen before...
      when /.*number1or2 hyphen number1or2 hyphen number1or2.*/
        :tag_numeric_month_day_short_year
      when /.*year hyphen number1or2 hyphen number1or2.*/
        :tag_year_numeric_month_day
        # ...this
      when /.*number1or2 hyphen number1or2 hyphen year.*/
        :tag_numeric_month_day_year
      when /.*year hyphen number1or2 hyphen year hyphen number1or2.*/
        :tag_year_plus_numeric_month_or_season
      when /.*year hyphen number1or2.*/
        :tag_year_plus_numeric_month_season_or_year
      when /.* hyphen .*/
        :tag_hyphen_as_range_indicator
      end
    end

    # types = Array with 2 Segment.type symbols
    # category = String that gets prepended to "date_part" to call DatePart building method
    def collapse_pair(to_collapse, target_type)
      sources = if to_collapse[0].is_a?(Symbol)
        result.extract(*to_collapse).segments
      else
        to_collapse
      end
      replace_multi_with_date_part_type(sources: sources,
        date_part_type: target_type)
    end

    def hyphen_to_range_indicator(source:)
      ri = Emendate::DerivedToken.new(type: :range_indicator,
        sources: [source])
      replace_x_with_given_segment(x: source, segment: ri)
    end

    def tag_numeric_month
      source = result.extract([:number1or2]).segments.first
      replace_x_with_date_part_type(x: source, date_part_type: :month)
    end

    def tag_century_num
      collapse_pair(%i[number1or2 century], :century)
    end

    def tag_day_in_mdy
      m, d, y = result.extract(:month, :number1or2, :year).segments
      unless valid_date?(
        y, m, d
      )
        raise UntaggableDatePartError.new(d,
          "invalid day value")
      end

      replace_x_with_date_part_type(x: d, date_part_type: :day)
    end

    def tag_pluralized_year
      if Emendate.options.pluralized_date_interpretation == :decade
        pair = result.extract(:year, :letter_s).segments
        collapse_pair(pair, :decade)
        result.warnings << "Interpreting pluralized year as decade" if pair[0].lexeme.end_with?("00")
      else
        year, _letter_s = result.extract(%i[year letter_s]).segments
        zeros = year.lexeme.match(/(0+)/)[1]
        case zeros.length
        when 1
          collapse_pair(%i[year letter_s], :decade)
        when 2
          collapse_pair(%i[year letter_s], :century)
          result.warnings << "Interpreting pluralized year as century"
        when 3
          collapse_pair(%i[year letter_s], :millennium)
          result.warnings << "Interpreting pluralized year as millennium"
        when 4
          collapse_pair(%i[year letter_s], :millennium)
          result.warnings << "Interpreting pluralized year as millennium"
        else
          # there should be no other variations, as only 4-digit years are
          #   tagged as years at this point (and 3-digit years that have been
          #   padded out to 4 digits to simplify the processing)
        end
      end
    end

    def tag_with_uncertainty_digits
      ud = result.extract(%i[uncertainty_digits]).segments[0]
      prev = result[result.find_index(ud) - 1]
      case ud.lexeme.length
      when 1
        collapse_pair([prev.type, :uncertainty_digits], :decade)
      when 2
        collapse_pair([prev.type, :uncertainty_digits], :century)
      when 3
        collapse_pair([prev.type, :uncertainty_digits], :millennium)
      else
        new = new_date_part(:uncertain_date_part, [ud])
        replace_x_with_given_segment(x: y, segment: new)
      end
    end

    def tag_numeric_month_day_year
      n1, h1, n2, h2, _y = result.extract(
        %i[number1or2 hyphen number1or2 hyphen year]
      ).segments
      collapse_token_pair_backward(n2, h2)
      collapse_token_pair_backward(n1, h1)

      num1, num2, yr = result.extract(%i[number1or2 number1or2 year]).segments

      begin
        res = Emendate::MonthDayAnalyzer.call(num1, num2, yr)
      rescue Emendate::MonthDayError => e
        raise e
      else
        replace_x_with_date_part_type(x: res.month, date_part_type: :month)
        replace_x_with_date_part_type(x: res.day, date_part_type: :day)
      end
      res.warnings.each { |warn| result.warnings << warn }
    end

    def tag_year_in_month_short_year
      _mth, yr = result.extract(%i[month number1or2]).segments
      year = Emendate::ShortYearHandler.call(yr)
      replace_x_with_given_segment(x: yr, segment: year)
    end

    def tag_year_in_season_short_year
      _season, yr = result.extract(%i[season number1or2]).segments
      year = Emendate::ShortYearHandler.call(yr)
      replace_x_with_given_segment(x: yr, segment: year)
    end

    def tag_numeric_month_day_short_year
      to_convert = result.extract(%i[number1or2 hyphen number1or2 hyphen
        number1or2])
      begin
        analyzer = Emendate::AllShortMdyAnalyzer.call(to_convert)
      rescue Emendate::Error => e
        raise(e)
      end

      analyzer.warnings.each { |warn| result.warnings << warn }
      replace_segments_with_new(segments: to_convert.segments,
        new: analyzer.datetype)
    end

    def tag_year_numeric_month_day
      y, h1, m, h2, _d = result.extract(
        %i[year hyphen number1or2 hyphen number1or2]
      ).segments
      collapse_token_pair_backward(m, h2)
      collapse_token_pair_backward(y, h1)

      yr, mth, day = result.extract(%i[year number1or2 number1or2]).segments

      unless valid_date?(yr, mth, day)
        raise UntaggableDatePatternError.new(
          [yr, mth, day], "returns invalid date"
        )
      end

      replace_x_with_date_part_type(x: mth, date_part_type: :month)
      replace_x_with_date_part_type(x: day, date_part_type: :day)
    end

    def tag_year_plus_numeric_month_or_season
      month_year_opt = Emendate.options.ambiguous_month_year.dup
      Emendate.config.options.ambiguous_month_year = :as_month

      y1, h1, _m1, _h2, y2, h3, _m2 = result.extract(
        %i[year hyphen number1or2 hyphen year hyphen number1or2]
      ).segments
      collapse_token_pair_backward(y2, h3)
      collapse_token_pair_backward(y1, h1)

      yr1, mth1, hyp, yr2, mth2 = result.extract(
        %i[year number1or2 hyphen year number1or2]
      ).segments

      [[yr1, mth1], [yr2, mth2]].each do |pair|
        analyzed = Emendate::MonthSeasonYearAnalyzer.call(
          year: pair[0], num: pair[1]
        )
        replace_x_with_given_segment(x: pair[1], segment: analyzed.result)
        analyzed.warnings.each { |warn| result.warnings << warn }
      end
      hyphen_to_range_indicator(source: hyp)

      Emendate.config.options.ambiguous_month_year = month_year_opt
    end

    def tag_year_plus_numeric_month_season_or_year
      y, h, m = result.extract(%i[year hyphen number1or2]).segments
      analyzed = Emendate::MonthSeasonYearAnalyzer.call(year: y, num: m)
      replace_x_with_given_segment(x: m, segment: analyzed.result)
      if analyzed.type == :year
        hyphen_to_range_indicator(source: h)
      else
        collapse_token_pair_backward(y, h)
      end
      analyzed.warnings.each { |warn| result.warnings << warn }
    end

    def tag_hyphen_as_range_indicator
      h = result.extract(%i[hyphen]).segments[0]
      hyphen_to_range_indicator(source: h)
    end

    def tag_years
      result.each do |t|
        next unless t.type == :number4
        next unless valid_year?(t.literal)

        replace_x_with_date_part_type(x: t, date_part_type: :year)
      end
    rescue Emendate::Error => e
      Failure(e)
    else
      Success()
    end
  end
end
