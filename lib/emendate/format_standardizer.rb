# frozen_string_literal: true

require_relative "date_utils"
require_relative "result_editable"

module Emendate
  # Makes the format of date patterns more consistent.
  #
  # Collapses some segments (e.g. comma in "Jan 1, 2000").
  #
  # Adds blank-lexeme segments (e.g. changing "Jan 2-5 2000" to "Jan 2
  # 2000 - Jan 5 2000). These add the necessary type and literal
  # information without changing the lexeme value.
  #
  # @todo Clean all date part tagging and date segmentation (i.e. creation of
  #    date type objects) from this step
  class FormatStandardizer
    include DateUtils
    include Dry::Monads[:result]
    include ResultEditable

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = Emendate::SegmentSets::SegmentSet.new.copy(tokens)
    end

    def call
      while standardizable
        function = determine_standardizer
        break if function.nil?

        function.call
        TokenCollapser.call(result).either(
          ->(success) { @result = success },
          ->(failure) { next }
        )
      end
      Success(result)
    end

    private

    attr_reader :result

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
      true if determine_standardizer
    end

    def full_match_standardizers
      case result.types
      when %i[month number1or2]
        proc do
          yr = ShortYearHandler.call(result[1])
          replace_segments_with_new(segments: [result[1]], new: yr)
        end
      when %i[partial range_indicator partial number1or2 century]
        proc { copy_number_century_after_first_partial }
      when %i[partial range_indicator partial number4 letter_s]
        proc { copy_number_s_after_first_partial }
      end
    end

    def partial_match_standardizers
      case result.type_string
      when /^double_dot.*/
        proc { open_start }
      when /.*double_dot$/
        proc { open_end }
      when /.*hyphen$/
        proc { handle_ending_hyphen }
      when /.*slash$/
        proc { handle_ending_slash }
      when /.*(?:range_indicator|hyphen|slash) unknown_date$/
        proc { unknown_end }
      when /.*slash.*/
        proc { replace_slash_with_hyphen }
      when /.*era_ce.*/
        proc { remove_ce_eras }
      when /.*letter_t number1or2 colon.*/
        proc { remove_time_parts }
      when /.*number3 uncertainty_digits.*/
        proc { decade_as_year }
      when /.*number3.*/
        proc { pad_3_to_4_digits }
      when /.*single_dot standalone_zero$/
        proc { remove_ending_dot_zero }
      when /.*number1or2 letter_c.*/
        proc { replace_c_with_century }
      when /.*number4 hyphen number4 era_bce.*/
        proc { copy_era_after_first_year }
      end
    end

    def full_match_date_part_standardizers
      case result.date_part_types
      when %i[number1or2 number1or2 century]
        proc { add_century_after_first_number }
      when %i[month month number4]
        proc { add_year_after_first_month }
      when %i[month number1or2 month number1or2 number4]
        proc { add_year_after_first_number1or2 }
      when %i[month number1or2 number1or2 number4]
        proc do
          add_year_after_first_number1or2
          add_month_before_second_number1or2
        end
      when %i[number4 month month]
        proc do
          segs = result.extract_by_date_part(%i[number4 month month])
          convert_year(segs[0])
          add_year_after_second_month
        end
      end
    end

    def add_century_after_first_number
      century = result[-1].dup
      century.reset_lexeme
      centuryless = result.find { |t| t.type == :number1or2 }
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
      yr = result.when_type(:year)[0].dup
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
        new_ind = Emendate::Segment.new(
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

    def convert_year(segment)
      replace_x_with_derived_new_type(x: segment, type: :year)
    end

    # @todo simplify with result_editable methods?
    def pad_3_to_4_digits
      t3 = result.find { |t| t.type == :number3 }
      t3i = result.find_index(t3)
      t4 = Emendate::Segment.new(
        type: :number4,
        sources: [t3]
      )
      result.delete_at(t3i)
      result.insert(t3i, t4)
    end

    def remove_post_year_hyphen
      year, hyphen = result.extract(%i[number4 hyphen]).segments
      collapse_token_pair_backward(year, hyphen)
    end

    def remove_time_parts
      t = Emendate::Segment.new(type: :time, sources: time_parts)
      replace_segments_with_new(segments: time_parts, new: t)
      collapse_last_token
    end

    def time_parts
      case result.type_string
      # rubocop:todo Layout/LineLength
      when /.*letter_t number1or2 colon number1or2 colon number1or2 hyphen number1or2.*/
        # rubocop:enable Layout/LineLength
        result.extract(
          %i[letter_t number1or2 colon number1or2 colon number1or2 hyphen
            number1or2]
        ).segments
      when /.*letter_t number1or2 colon number1or2 colon number1or2 letter_z.*/
        result.extract(
          %i[letter_t number1or2 colon number1or2 colon number1or2 letter_z]
        ).segments
      # rubocop:todo Layout/LineLength
      when /.*letter_t number1or2 colon number1or2 colon number1or2 plus number1or2 colon number1or2.*/
        # rubocop:enable Layout/LineLength
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
      ht = Emendate::Segment.new(type: :hyphen, lexeme: slash.lexeme)
      replace_x_with_new(x: slash, new: ht)
    end

    def remove_ending_dot_zero
      zero = result.segments[-1]
      dot = result.segments[-2]
      previous = result.segments[-3]
      derived = Emendate::Segment.new(
        type: previous.type,
        sources: [previous, dot, zero]
      )
      replace_segments_with_new(segments: [previous, dot, zero], new: derived)
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
