# frozen_string_literal: true

require_relative './result_editable'

module Emendate
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
          move_x_to_end(result[0])
        end
      when %i[number4 hyphen month]
        proc do
          remove_post_year_hyphen
          move_x_to_end(result[0])
        end
      when %i[number4 comma season]
        proc do
          remove_post_year_comma
          move_x_to_end(result[0])
        end
      when %i[number4 comma month number1or2]
        proc do
          remove_post_year_comma
          move_year_to_end_of_segment
        end
      when %i[number1or2 hyphen number4]
        proc{ reverse_tokens }
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
        proc{ remove_post_month_comma }
      when /.*number4 month number1or2.*/
        proc{ move_year_to_end_of_segment }
      when /.*number1or2 month number4.*/
        proc{ move_month_to_beginning_of_segment }
      when /.*number1or2 letter_c.*/
        proc{ replace_c_with_century }
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
          move_year_after_first_month
          add_year_after_second_month
        end
      end
    end

    def reverse_tokens
      tmp = []
      tmp << result.segments.pop until result.segments.empty?
      tmp.each{ |segment| result.segments << segment }
    end

    def add_century_after_first_number
      century = result[-1].dup
      centuryless = result.select{ |t| t.type == :number1or2 }[0]
      ins_pt = result.find_index(centuryless) + 1
      result.insert(ins_pt, century)
    end

    def add_month_before_second_number1or2
      month = result.when_type(:month)[0].dup
      day2 = result.when_type(:number1or2)[1]
      ins_pt = result.find_index(day2)
      result.insert(ins_pt, month)
    end

    def add_year_after_first_month
      yr = result.when_type(:number4)[0].dup
      month1 = result.when_type(:month)[0]
      ins_pt = result.find_index(month1) + 1
      result.insert(ins_pt, yr)
    end

    def add_year_after_second_month
      yr = result.when_type(:number4)[0].dup
      month2 = result.when_type(:month)[1]
      ins_pt = result.find_index(month2) + 1
      result.insert(ins_pt, yr)
    end

    def add_year_after_first_number1or2
      yr = result.when_type(:number4)[0].dup
      day1 = result.when_type(:number1or2)[0]
      ins_pt = result.find_index(day1) + 1
      result.insert(ins_pt, yr)
    end

    def copy_number_century_after_first_partial
      cent = result.extract(%i[number1or2 century]).segments
      p = result.extract(%i[partial]).segments[0]
      ins_pt = result.find_index(p) + 1
      cent.each do |c|
        result.insert(ins_pt, c.dup)
        ins_pt += 1
      end
    end

    def copy_number_s_after_first_partial
      decade = result.extract(%i[number4 letter_s]).segments
      p = result.extract(%i[partial]).segments[0]
      ins_pt = result.find_index(p) + 1
      decade.each do |c|
        result.insert(ins_pt, c.dup)
        ins_pt += 1
      end
    end

    # @param indicator [#segment?] to be converted to range indicator type if
    #   not already that type
    # @param klass [Constant] target date_type class name
    def convert_range_indicator_and_append_open_or_unknown_end_date(
      indicator:, klass:
    )
      unless indicator.type == :range_indicator
        new_ind = Emendate::DerivedToken.new(
          type: :range_indicator,
          sources: [indicator]
        )
        replace_x_with_new(x: indicator, new: new_ind)
      end
      result << klass.new(usage: :end)
    end

    def handle_ending_hyphen
      convert_range_indicator_and_append_open_or_unknown_end_date(
        indicator: result[-1],
        klass: Emendate::DateTypes::RangeDateOpen
      )
    end

    def handle_ending_slash
      setting = Emendate.config.options.ending_slash
      klass = if setting == :open
                Emendate::DateTypes::RangeDateOpen
              else
                Emendate::DateTypes::RangeDateUnknown
              end
      convert_range_indicator_and_append_open_or_unknown_end_date(
        indicator: result[-1],
        klass: klass
      )
    end

    def move_month_to_beginning_of_segment
      _n1, mth, _n4 = result.extract(%i[number1or2 month number4]).segments
      m_ind = result.find_index(mth)
      d_ind = m_ind - 1
      result.delete_at(m_ind)
      result.insert(d_ind, mth)
    end

    def move_year_after_first_month
      yr = result.when_type(:number4)[0]
      result.delete(yr)
      month1 = result.when_type(:month)[0]
      ins_pt = result.find_index(month1) + 1
      result.insert(ins_pt, yr)
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
      lexeme4 = t3.lexeme.rjust(4, '0')
      t4 = Emendate::DerivedToken.new(
        type: :number4,
        lexeme: lexeme4,
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
      time_parts.each{ |s| result.delete(s) }
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
      decade = Emendate::DateTypes::Decade.new(literal: num3.literal,
                                               decade_type: :uncertainty_digits,
                                               children: [num3, udigits])
      replace_segments_with_new(segments: [num3, udigits], new: decade)
    end

    def open_start
      firsttoken = result[0]
      openstart = Emendate::DateTypes::RangeDateOpen.new(
        usage: :start
      )
      replace_x_with_new(x: firsttoken, new: openstart)
    end

    def open_end
      open_or_unknown_end(Emendate::DateTypes::RangeDateOpen)
    end

    def unknown_end
      open_or_unknown_end(Emendate::DateTypes::RangeDateUnknown)
    end

    def open_or_unknown_end(klass)
      lasttoken = result[-1]
      openend = klass.new(
        usage: :end,
        children: [lasttoken]
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
                               literal: '-',
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
      e = result.extract(%i[era_ce]).segments[0]
      result.delete(e)
    end
  end
end
