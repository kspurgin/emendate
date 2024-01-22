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
      @result = Emendate::SegmentSet.new.copy(tokens)
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

        t.call
      end
    rescue Emendate::Error => e
      Failure(e)
    else
      Success()
    end

    def determine_tagger
      t = full_match_tagger
      return t unless t.nil?

      t = full_match_date_part_tagger
      return t unless t.nil?

      t = partial_match_tagger
      @taggable = false if t.nil?
      t
    end

    def full_match_tagger
      case result.type_string
      # The order of the following two
      when /^number1or2 year$/
        proc { tag_numeric_month }
      when /^year number1or2$/
        proc { tag_year_plus_numeric_month_season_or_year }
      end
    end

    def full_match_date_part_tagger
      # case result.date_part_types.sort.join(" ")
      # end
    end

    def partial_match_tagger
      case result.type_string
      when /.*year letter_s.*/
        proc { tag_pluralized_year }
      when /.*uncertainty_digits.*/
        proc { tag_with_uncertainty_digits }
      when /.*number1or2 century.*/
        proc { tag_century_num }
      when /.*number1or2 month year.*/
        proc { tag_day_in_dmy }
      when /.*year month number1or2.*/
        proc { tag_day_in_ymd }
      when /.*month number1or2 year.*/
        proc { tag_day_in_mdy }
      when /.*season number1or2.*/
        proc { tag_year_in_season_short_year }
      when /.*month number1or2.*/
        proc { tag_year_in_month_short_year }
        # this needs to happen before...
      when /.*number1or2 number1or2 number1or2.*/
        proc { tag_numeric_month_day_short_year }
      when /.*year hyphen number1or2 hyphen number1or2.*/
        proc { tag_year_numeric_month_day }
      # ...this
      when /.*number1or2 number1or2 year.*/
        proc { tag_numeric_month_day_year }
      when /.*year hyphen number1or2 hyphen year hyphen number1or2.*/
        proc { tag_year_plus_numeric_month_or_season }
      when /.*year number1or2.*/
        proc { tag_year_plus_numeric_month_season_or_year }
      when /.* hyphen .*/
        proc { tag_hyphen_as_range_indicator }
      end
    end

    def collapse_pair(to_collapse, target_type)
      sources = if to_collapse[0].is_a?(Symbol)
        result.extract(*to_collapse).segments
      else
        to_collapse
      end
      replace_segs_with_new_type(segs: sources, type: target_type)
    end

    def hyphen_to_range_indicator(source:)
      ri = Emendate::Segment.new(type: :range_indicator,
        sources: [source])
      replace_x_with_new(x: source, new: ri)
    end

    def tag_numeric_month
      source = result.extract([:number1or2]).segments.first
      replace_x_with_date_part_type(x: source, date_part_type: :month)
    end

    def tag_century_num
      replace_segtypes_with_new_type(old: %i[number1or2 century], new: :century)
    end

    def tag_day(yr:, mth:, day:)
      replace_x_with_date_part_type(x: day, date_part_type: :day)
    end

    def tag_day_in_ymd
      y, m, d = result.extract(:year, :month, :number1or2).segments
      tag_day(yr: y, mth: m, day: d)
    end

    def tag_day_in_dmy
      d, m, y = result.extract(:number1or2, :month, :year).segments
      tag_day(yr: y, mth: m, day: d)
    end

    def tag_day_in_mdy
      m, d, y = result.extract(:month, :number1or2, :year).segments
      tag_day(yr: y, mth: m, day: d)
    end

    def tag_pluralized_year
      if Emendate.options.pluralized_date_interpretation == :decade
        pair = result.extract(:year, :letter_s).segments
        replace_segtypes_with_new_type(old: %i[year letter_s], new: :decade)

        if pair[0].lexeme.end_with?("00")
          result.warnings << "Interpreting pluralized year as decade"
        end
      else
        segs = result.extract(%i[year letter_s]).segments
        zeros = segs[0].lexeme.match(/(0+)/)[1]
        case zeros.length
        when 1
          replace_segs_with_new_type(segs: segs, type: :decade)
        when 2
          replace_segs_with_new_type(segs: segs, type: :century)
          result.warnings << "Interpreting pluralized year as century"
        when 3
          replace_segs_with_new_type(segs: segs, type: :millennium)
          result.warnings << "Interpreting pluralized year as millennium"
        when 4
          replace_segs_with_new_type(segs: segs, type: :millennium)
          result.warnings << "Interpreting pluralized year as millennium"
        else
          # there should be no other variations, as only 4-digit years are
          #   tagged as years at this point (and 3-digit years that have been
          #   padded out to 4 digits to simplify the processing)
          raise Emendate::UnexpectedPluralizedYearPatternError
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
        new = Emendate::Segment.new(type: :uncertain_date_part, sources: [ud])
        replace_x_with_new(x: y, new: new)
      end
    end

    def tag_numeric_month_day_year
      num1, num2, yr = result.extract(%i[number1or2 number1or2 year]).segments

      res = Emendate::MonthDayAnalyzer.call(num1, num2, yr)
      replace_x_with_date_part_type(x: res.month, date_part_type: :month)
      replace_x_with_date_part_type(x: res.day, date_part_type: :day)
      res.warnings.each { |warn| result.warnings << warn }
    end

    def tag_year_in_month_short_year
      _mth, yr = result.extract(%i[month number1or2]).segments
      year = Emendate::ShortYearHandler.call(yr)
      replace_x_with_new(x: yr, new: year)
    end

    def tag_year_in_season_short_year
      _season, yr = result.extract(%i[season number1or2]).segments
      year = Emendate::ShortYearHandler.call(yr)
      replace_x_with_new(x: yr, new: year)
    end

    def tag_numeric_month_day_short_year
      to_convert = result.extract(%i[number1or2 number1or2 number1or2])
      analyzed = Emendate::AllShortMdyAnalyzer.call(to_convert)

      replace_segments_with_new_segment_set(segments: to_convert.segments,
        new: analyzed)
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
        replace_x_with_new(x: pair[1], new: analyzed.result)
        analyzed.warnings.each { |warn| result.warnings << warn }
      end
      hyphen_to_range_indicator(source: hyp)

      Emendate.config.options.ambiguous_month_year = month_year_opt
    end

    def tag_year_plus_numeric_month_season_or_year
      y, n = result.extract(%i[year number1or2]).segments
      analyzed = Emendate::MonthSeasonYearAnalyzer.call(year: y, num: n)
      replace_x_with_new(x: n, new: analyzed.result)
      insert_dummy_after_segment(y, :range_indicator) if analyzed.type == :year
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
