# frozen_string_literal: true

require_relative './result_editable'

module Emendate
  # Makes the format of date patterns more consistent.
  #
  # Collapses some segments (e.g. comma in "Jan 1, 2000").
  #
  # Adds blank-lexeme segments (e.g. changing "Jan 2-5 2000" to "Jan 2
  # 2000 - Jan 5 2000). These add the necessary type and literal
  # information without changing the lexeme value.
  #
  # The next processing step ({DatePartTagger}) assumes date parts will be in
  # orders:
  #
  # * month day year
  # * season year
  # * month year
  # * number century
  #
  # When segments are in different orders, this class directly
  # converts them to date type segments. Changing the order of segments messes
  # up the lexeme value, so we simplify later processing by converting
  # directly to date type segments when we can.
  class FormatStandardizer
    include Dry::Monads[:result]
    include ResultEditable

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = tokens.class.new.copy(tokens)
    end

    def call
      while standardizable
        function = determine_standardizer
        break if function.nil?

        function.call
      end
      Success(result)
    end

    private

    attr_reader :result, :standardizable

    def determine_standardizer
      fms = full_match_standardizers
      return fms unless fms.nil?

      ps = partial_match_standardizers
      return ps unless ps.nil?

      fmdp = full_match_date_part_standardizers
      return fmdp unless fmdp.nil?

      nil
    end

    def standardizable
      return true if determine_standardizer
    end

    def full_match_standardizers
      case result.types
      when %i[number4 comma month]
        proc do
          remove_post_year_comma
          new_datetype(type: :ym, sources: result[0..1], ind: [0, 1])
        end
      when %i[number4 hyphen month]
        proc do
          remove_post_year_hyphen
          new_datetype(type: :ym, sources: result[0..1], ind: [0, 1])
        end
      when %i[number4 comma season]
        proc do
          remove_post_year_comma
          new_datetype(type: :ys, sources: result[0..1], ind: [0, 1])
        end
      when %i[number4 comma month number1or2]
        proc do
          remove_post_year_comma
          new_datetype(type: :ymd, sources: result[0..2], ind: [0, 1, 2])
        end
      when %i[number1or2 month number4]
        proc do
          new_datetype(type: :ymd, sources: result[0..2], ind: [2, 1, 0])
        end
      when %i[number1or2 hyphen number4]
        proc do
          collapse_token_pair_forward(result[0], result[1])
          year_plus_ambiguous_month_season
        end
      when %i[partial range_indicator partial number1or2 century]
        proc{ copy_number_century_after_first_partial }
      when %i[partial range_indicator partial number4 letter_s]
        proc{ copy_number_s_after_first_partial }
      end
    end

    def partial_match_standardizers
      case result.type_string
      when /^double_dot.*/
        proc{ open_start }
      when /.*double_dot$/
        proc{ open_end }
      when /.*hyphen$/
        proc{ handle_ending_hyphen }
      when /.*slash$/
        proc{ handle_ending_slash }
      when /.*(?:range_indicator|hyphen|slash) unknown_date$/
        proc{ unknown_end }
      when /.*slash.*/
        proc{ replace_slash_with_hyphen }
      when /.*era_ce.*/
        proc{ remove_ce_eras }
      when /.*letter_t number1or2 colon.*/
        proc{ remove_time_parts }
      when /.*number3 uncertainty_digits.*/
        proc{ decade_as_year }
      when /.*number3.*/
        proc{ pad_3_to_4_digits }
      when /.*single_dot standalone_zero$/
        proc{ remove_ending_dot_zero }
      when /.*month number1or2 comma number4.*/
        proc do
          tokens = result.extract(%i[month number1or2 comma number4]).segments
          collapse_token_pair_backward(tokens[1], tokens[2])
        end
      when /.*number4 month number1or2.*/
        proc do
          tokens = result.extract(%i[number4 month number1or2]).segments
          dt = new_datetype(type: :ymd, sources: tokens, ind: [0, 1, 2],
                            whole: false)
          replace_segments_with_new(segments: tokens, new: dt)
        end
      when /.*number1or2 month number4.*/
        proc do
          tokens = result.extract(%i[number1or2 month number4]).segments
          dt = new_datetype(type: :ymd, sources: tokens, ind: [2, 0, 1],
                            whole: false)
          replace_segments_with_new(segments: tokens, new: dt)
        end
      when /.*month number1or2 hyphen yearmonthday_date_type.*/
        proc do
          tokens = result.extract(
            %i[month number1or2 hyphen yearmonthday_date_type]
          ).segments
          ymd = tokens[3]
          yr = Emendate::Token.new(type: :dummy, literal: ymd.year)
          dt = new_datetype(type: :ymd,
                            sources: [yr, tokens[0], tokens[1]],
                            ind: [0, 1, 2],
                            whole: false)
          replace_segments_with_new(segments: [tokens[0], tokens[1]], new: dt)
        end
      when /.*number1or2 letter_c.*/
        proc{ replace_c_with_century }
      when /.*number4 hyphen number4 era_bce.*/
        proc{ copy_era_after_first_year }
      end
    end

    def full_match_date_part_standardizers
      case result.date_part_types
      when %i[number1or2 number1or2 century]
        proc{ add_century_after_first_number }
      when %i[month month number4]
        proc{ add_year_after_first_month }
      when %i[month number1or2 month number1or2 number4]
        proc{ add_year_after_first_number1or2 }
      when %i[month number1or2 number1or2 number4]
        proc do
          add_year_after_first_number1or2
          add_month_before_second_number1or2
        end
      when %i[number4 month month]
        proc do
          add_year_after_second_month
          move_year_after_first_month
        end
      end
    end

    def new_datetype(type:, sources:, ind:, whole: true)
      klass = case type
              when :ym
                Emendate::DateTypes::YearMonth
              when :ys
                Emendate::DateTypes::YearSeason
              when :ymd
                Emendate::DateTypes::YearMonthDay
              end
      args = case type
             when :ym
               { year: sources[ind[0]].literal,
                 month: sources[ind[1]].literal,
                 sources: sources }
             when :ys
               { year: sources[ind[0]].literal,
                 season: sources[ind[1]].literal,
                 sources: sources }
             when :ymd
               { year: sources[ind[0]].literal,
                 month: sources[ind[1]].literal,
                 day: sources[ind[2]].literal,
                 sources: sources }
             end
      dt = klass.new(**args)
      return dt unless whole

      result.clear
      result << dt
    end

    def year_plus_ambiguous_month_season
      analyzed = Emendate::MonthSeasonYearAnalyzer.call(
        result[0], result[1]
      )
      replace_x_with_given_segment(x: result[0], segment: analyzed.result)
      type = case analyzed.type
             when :month then :ym
             when :season then :ys
             end
      new_datetype(type: type, sources: result[0..1], ind: [1, 0])
    end

    def add_century_after_first_number
      century = result[-1].dup
      century.reset_lexeme
      centuryless = result.select{ |t| t.type == :number1or2 }[0]
      ins_pt = result.find_index(centuryless) + 1
      result.insert(ins_pt, century)
    end

    def add_month_before_second_number1or2
      month = result.when_type(:month)[0].dup
      month.reset_lexeme
      day2 = result.when_type(:number1or2)[1]
      ins_pt = result.find_index(day2)
      result.insert(ins_pt, month)
    end

    def add_year_after_first_month
      yr = result.when_type(:number4)[0].dup
      yr.reset_lexeme
      month1 = result.when_type(:month)[0]
      ins_pt = result.find_index(month1) + 1
      result.insert(ins_pt, yr)
    end

    def add_year_after_second_month
      yr = result.when_type(:number4)[0].dup
      yr.reset_lexeme
      month2 = result.when_type(:month)[1]
      ins_pt = result.find_index(month2) + 1
      result.insert(ins_pt, yr)
    end

    def add_year_after_first_number1or2
      yr = result.when_type(:number4)[0].dup
      yr.reset_lexeme
      day1 = result.when_type(:number1or2)[0]
      ins_pt = result.find_index(day1) + 1
      result.insert(ins_pt, yr)
    end

    def copy_number_century_after_first_partial
      cent = result.extract(%i[number1or2 century]).segments
      p = result.extract(%i[partial]).segments[0]
      ins_pt = result.find_index(p) + 1
      cent.each do |c|
        newseg = c.dup
        newseg.reset_lexeme
        result.insert(ins_pt, newseg)
        ins_pt += 1
      end
    end

    def copy_era_after_first_year
      n1, _h, _n2, era = result.extract(%i[number4 hyphen number4 era_bce])
                               .segments
      ins_pt = result.find_index(n1) + 1
      newseg = era.dup
      newseg.reset_lexeme
      result.insert(ins_pt, newseg)
    end

    def copy_number_s_after_first_partial
      decade = result.extract(%i[number4 letter_s]).segments
      p = result.extract(%i[partial]).segments[0]
      ins_pt = result.find_index(p) + 1
      decade.each do |c|
        newseg = c.dup
        newseg.reset_lexeme
        result.insert(ins_pt, newseg)
        ins_pt += 1
      end
    end

    # @param indicator [#segment?] to be converted to range indicator type if
    #   not already that type
    # @param category [:open, :unknown]
    def convert_range_indicator_and_append_open_or_unknown_end_date(
      indicator:, category:
    )
      unless indicator.type == :range_indicator
        new_ind = Emendate::DerivedToken.new(
          type: :range_indicator,
          sources: [indicator]
        )
        replace_x_with_new(x: indicator, new: new_ind)
      end
      result << Emendate::DateTypes::RangeDateUnknownOrOpen.new(
        category: category, point: :end, sources: nil
      )
    end

    def handle_ending_hyphen
      convert_range_indicator_and_append_open_or_unknown_end_date(
        indicator: result[-1],
        category: Emendate.config.options.ending_hyphen
      )
    end

    def handle_ending_slash
      convert_range_indicator_and_append_open_or_unknown_end_date(
        indicator: result[-1],
        category: Emendate.config.options.ending_slash
      )
    end

    def move_year_after_first_month
      yr = result.when_type(:number4)[0]
      mth = result.when_type(:month)[0]
      dt = new_datetype(type: :ym,
                        sources: [yr, mth],
                        ind: [0, 1],
                        whole: false)
      replace_segments_with_new(segments: [yr, mth], new: dt)
    end

    def move_year_to_end_of_segment
      yr = result.select do |t|
        t.type == :number4 &&
          result[result.find_index(t) + 1].type == :month &&
          result[result.find_index(t) + 2].type == :number1or2
      end[0]
      y_ind = result.find_index(yr)
      ins_pt = y_ind + 3
      result.insert(ins_pt, yr.dup)
      result.delete_at(y_ind)
    end

    def pad_3_to_4_digits
      t3 = result.select{ |t| t.type == :number3 }[0]
      t3i = result.find_index(t3)
      t4 = Emendate::DerivedToken.new(
        type: :number4,
        sources: [t3]
      )
      result.delete_at(t3i)
      result.insert(t3i, t4)
    end

    def remove_post_month_comma
      _month, day, comma = result.extract(%i[month number1or2 comma]).segments
      collapse_token_pair_backward(day, comma)
    end

    def remove_post_year_comma
      year, comma = result.extract(%i[number4 comma]).segments
      collapse_token_pair_backward(year, comma)
    end

    def remove_post_year_hyphen
      year, hyphen = result.extract(%i[number4 hyphen]).segments
      collapse_token_pair_backward(year, hyphen)
    end

    def remove_time_parts
      t = Emendate::DerivedToken.new(type: :time, sources: time_parts)
      replace_segments_with_new(segments: time_parts, new: t)
      collapse_last_token
    end

    def time_parts
      case result.type_string
      when /.*letter_t number1or2 colon number1or2 colon number1or2 hyphen number1or2.*/
        result.extract(
          %i[letter_t number1or2 colon number1or2 colon number1or2 hyphen
             number1or2]
        ).segments
      when /.*letter_t number1or2 colon number1or2 colon number1or2 letter_z.*/
        result.extract(
          %i[letter_t number1or2 colon number1or2 colon number1or2 letter_z]
        ).segments
      when /.*letter_t number1or2 colon number1or2 colon number1or2 plus number1or2 colon number1or2.*/
        pattern = %i[letter_t number1or2 colon number1or2 colon number1or2 plus
                     number1or2 colon number1or2]
        result.extract(pattern).segments
        # the following must come last as it is a substring of the previous
      when /.*letter_t number1or2 colon number1or2 colon number1or2.*/
        result.extract(
          %i[letter_t number1or2 colon number1or2 colon number1or2]
        ).segments
      end
    end

    def decade_as_year
      num3 = result.when_type(:number3)[0]
      udigits = result.when_type(:uncertainty_digits)[0]
      decade = Emendate::DateTypes::Decade.new(sources: [num3, udigits])
      replace_segments_with_new(segments: [num3, udigits], new: decade)
    end

    def open_start
      firsttoken = result[0]
      openstart = Emendate::DateTypes::RangeDateUnknownOrOpen.new(
        category: :open, point: :start, sources: [firsttoken]
      )
      replace_x_with_new(x: firsttoken, new: openstart)
    end

    def open_end
      open_or_unknown_end(:open)
    end

    def unknown_end
      open_or_unknown_end(:unknown)
    end

    def open_or_unknown_end(category)
      lasttoken = result[-1]
      openend = Emendate::DateTypes::RangeDateUnknownOrOpen.new(
        category: category,
        point: :end,
        sources: [lasttoken]
      )
      replace_x_with_new(x: lasttoken, new: openend)
    end

    def replace_c_with_century
      _yr, c = result.extract(%i[number1or2 letter_c]).segments
      replace_x_with_derived_new_type(x: c, type: :century)
    end

    def replace_slash_with_hyphen
      slash = result.when_type(:slash)[0]
      ht = Emendate::Token.new(type: :hyphen,
                               lexeme: slash.lexeme,
                               location: slash.location)
      replace_x_with_new(x: slash, new: ht)
    end

    def remove_ending_dot_zero
      zero = result.segments[-1]
      dot = result.segments[-2]
      previous = result.segments[-3]
      derived = Emendate::DerivedToken.new(
        type: previous.type,
        sources: [previous, dot, zero]
      )
      replace_segments_with_new(segments: [previous, dot, zero], new: derived)
    end

    def remove_post_partial_hyphen
      _p, h = result.extract(%i[partial hyphen]).segments
      result.delete(h)
    end

    def remove_ce_eras
      ces = result.extract(%i[era_ce]).segments
      ces.each do |ce|
        ce_ind = result.find_index(ce)
        if ce_ind == 0
          collapse_first_token
        else
          prev = ce_ind - 1
          collapse_token_pair_backward(result[prev], ce)
        end
      end
    end
  end
end
