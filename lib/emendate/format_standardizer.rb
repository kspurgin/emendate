# frozen_string_literal: true

module Emendate

  class FormatStandardizer
    include ResultEditable
    attr_reader :result, :standardizable

    def initialize(tokens:, options: {})
      @options = options.options
      @result = tokens.class.new.copy(tokens)
      @standardizable = true
    end

    def standardize
      while standardizable
        functions = determine_standardizers
        break if functions.nil?

        functions.each{ |f| send(f) }
      end
      result
    end

    private

    def determine_standardizers
      s = partial_match_standardizers
      return s unless s.nil?

      s = full_match_date_part_standardizers
      return s unless s.nil?

      s = full_match_standardizers
      @standardizable = false if s.nil?
      s
    end

    def partial_match_standardizers
      case result.type_string
      when /^double_dot.*/
        %i[open_start]
      when /.*slash.*/
        %i[replace_slash_with_hyphen]
      when /.*era.*/
        %i[remove_ce_eras]
      when /.*letter_t number1or2 colon.*/
        %i[remove_time_parts]
      when/.*number3.*/
        %i[pad_3_to_4_digits]
      when /.*partial hyphen.*/
        %i[remove_post_partial_hyphen]
      when /.*month number1or2 comma number4.*/
        %i[remove_post_month_comma]
      when /.*number4 month number1or2.*/
        %i[move_year_to_end_of_segment]
      when /.*number1or2 month number4.*/
        %i[move_month_to_beginning_of_segment]
      end
    end

    def full_match_date_part_standardizers
      case result.date_part_types
      when %i[number1or2 number1or2 century]
        %i[add_century_after_first_number]
      when %i[month month number4]
        %i[add_year_after_first_month]
      when %i[month number1or2 month number1or2 number4]
        %i[add_year_after_first_number1or2]
      when %i[month number1or2 number1or2 number4]
        %i[add_year_after_first_number1or2
           add_month_before_second_number1or2]
      when %i[number4 month month]
        %i[move_year_after_first_month
           add_year_after_second_month]
      end
    end

    def full_match_standardizers
      case result.types
      when %i[partial range_indicator partial number1or2 century]
        %i[copy_number_century_after_first_partial]
      end
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

    def move_month_to_beginning_of_segment
      _n1, mth, _n4 = result.extract(%i[number1or2 month number4]).segments
      m_ind = result.find_index(mth)
      d_ind =  m_ind - 1
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
      yr = result.select{ |t| t.type == :number4 &&
          result[result.find_index(t) + 1].type == :month &&
          result[result.find_index(t) + 2].type == :number1or2 }[0]
      y_ind = result.find_index(yr)
      ins_pt = y_ind + 3
      result.insert(ins_pt, yr.dup)
      result.delete_at(y_ind)
    end

    def pad_3_to_4_digits
      t3 = result.select{ |t| t.type == :number3 }[0]
      t3i = result.find_index(t3)
      lexeme4 = t3.lexeme.rjust(4, '0')
      t4 = Emendate::NumberToken.new(type: :number, lexeme: lexeme4, literal: t3.literal, location: t3.location)
      result.delete_at(t3i)
      result.insert(t3i, t4)
    end

    def remove_post_month_comma
      comma = result.extract(%i[month number1or2 comma]).segments[-1]
      result.delete(comma)
    end

    def remove_time_parts
      time_parts.each{ |s| result.delete(s) }
    end

    def time_parts
      case result.type_string
      when /.*letter_t number1or2 colon number1or2 colon number1or2 hyphen number1or2.*/
        result.extract(%i[letter_t number1or2 colon number1or2 colon number1or2 hyphen number1or2]).segments
      when /.*letter_t number1or2 colon number1or2 colon number1or2 letter_z.*/
        result.extract(%i[letter_t number1or2 colon number1or2 colon number1or2 letter_z]).segments
      when /.*letter_t number1or2 colon number1or2 colon number1or2 plus number1or2 colon number1or2.*/
        pattern = %i[letter_t number1or2 colon number1or2 colon number1or2 plus number1or2 colon number1or2]
        result.extract(pattern).segments
        # the following must come last as it is a substring of the previous
      when /.*letter_t number1or2 colon number1or2 colon number1or2.*/
        result.extract(%i[letter_t number1or2 colon number1or2 colon number1or2]).segments
      end
    end

    def open_start
      doubledot = result.when_type(:double_dot)[0]
      openstart = Emendate::DateTypes::OpenRangeDate.new(use_date: @options[:open_unknown_start_date],
                                                         usage: :start)
      replace_x_with_new(x: doubledot, new: openstart)
    end
    
    def replace_slash_with_hyphen
      slash = result.when_type(:slash)[0]
      ht = Emendate::Token.new(type: :hyphen,
                               lexeme: slash.lexeme,
                               literal: '-',
                               location: slash.location)
      replace_x_with_new(x: slash, new: ht)
    end

    def remove_post_partial_hyphen
      _p, h = result.extract(%i[partial hyphen]).segments
      result.delete(h)
    end

    def remove_ce_eras
      e = result.extract(%i[era]).segments[0]
      if e.lexeme == 'ce'
        result.delete(e)
      else
        ins_pt = result.find_index(e) + 1
        bce = Emendate::Token.new(type: :bce,
                                  lexeme: e.lexeme,
                                  literal: e.literal,
                                  location: e.location)
        result.insert(ins_pt, bce)
        result.delete(e)
      end
    end
  end
end
