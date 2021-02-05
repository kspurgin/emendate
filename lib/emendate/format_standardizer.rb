# frozen_string_literal: true

module Emendate
  
  class FormatStandardizer
  attr_reader :orig, :result, :standardizable
  def initialize(tokens:, options: {})
      @orig = tokens
      @result = tokens.clone
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

      s = full_match_standardizers
      standardizable = false if s.nil?
      s
    end

    def partial_match_standardizers
      case result.type_string
      when /.*slash.*/
        %i[replace_slash_with_hyphen]
      when/.*number3.*/
        %i[pad_3_to_4_digits]
      when /.*partial hyphen.*/
        %i[remove_post_partial_hyphen]
      when /.*number_month number1or2 comma number4.*/
        %i[remove_post_month_comma]
      when /.*number4 number_month number1or2.*/
        %i[move_year_to_end_of_segment]
      when /.*number1or2 number_month number4.*/
        %i[move_month_to_beginning_of_segment]
      end
    end
    
    def full_match_standardizers
      case result.date_part_types
      when %i[number1or2 number1or2 century]
        %i[add_century_after_first_number]
      when %i[number_month number_month number4]
        %i[add_year_after_first_month]
      when %i[number_month number1or2 number_month number1or2 number4]
        %i[add_year_after_first_number1or2]
      when %i[number_month number1or2 number1or2 number4]
        %i[add_year_after_first_number1or2
           add_month_before_second_number1or2]
      when %i[number4 number_month number_month]
        %i[move_year_after_first_month
           add_year_after_second_month]
      end
    end

    def add_century_after_first_number
      century = result[-1].dup
      centuryless = result.select{ |t| t.type == :number1or2 }[0]
      ins_pt = result.find_index(centuryless) + 1
      result.insert(ins_pt, century)
    end

    def add_month_before_second_number1or2
      month = result.when_type(:number_month)[0].dup
      day2 = result.when_type(:number1or2)[1]
      ins_pt = result.find_index(day2)
      result.insert(ins_pt, month)
    end

    def add_year_after_first_month
      yr = result.when_type(:number4)[0].dup
      month1 = result.when_type(:number_month)[0]
      ins_pt = result.find_index(month1) + 1
      result.insert(ins_pt, yr)
    end
    
    def add_year_after_second_month
      yr = result.when_type(:number4)[0].dup
      month2 = result.when_type(:number_month)[1]
      ins_pt = result.find_index(month2) + 1
      result.insert(ins_pt, yr)
    end

    def add_year_after_first_number1or2
      yr = result.when_type(:number4)[0].dup
      day1 = result.when_type(:number1or2)[0]
      ins_pt = result.find_index(day1) + 1
      result.insert(ins_pt, yr)
    end

    def move_month_to_beginning_of_segment
      n1, m, n4 = result.extract(%i[number1or2 number_month number_4]).segments
      # month = result.select{ |t| t.type == :number_month &&
      #     result[result.find_index(t) - 1].type == :number1or2 &&
      #     result[result.find_index(t) + 1].type == :number4 }[0]
      m_ind = result.find_index(m)
      d_ind =  m_ind - 1
      result.delete_at(m_ind)
      result.insert(d_ind, m)
    end
    
    def move_year_after_first_month
      yr = result.when_type(:number4)[0]
      result.delete(yr)
      month1 = result.when_type(:number_month)[0]
      ins_pt = result.find_index(month1) + 1
      result.insert(ins_pt, yr)
    end

    def move_year_to_end_of_segment
      yr = result.select{ |t| t.type == :number4 &&
          result[result.find_index(t) + 1].type == :number_month &&
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
      commas = result.select do |t|
        t.type == :comma &&
          result[result.find_index(t) - 2].type == :number_month &&
          result[result.find_index(t) - 1].type == :number1or2 &&
          result[result.find_index(t) + 1].type == :number4
      end
      commas.map{ |c| result.find_index(c) }
        .sort.reverse
        .each{ |i| result.delete_at(i) }
    end

    def replace_slash_with_hyphen
      slash = result.when_type(:slash)[0]
      si = result.find_index(slash)
      ht = Emendate::Token.new(type: :hyphen,
                               lexeme: slash.lexeme,
                               literal: '-',
                               location: slash.location)
      result.insert(si + 1, ht)
      result.delete(slash)
    end
    
    def remove_post_partial_hyphen
      p, h = result.extract(%i[partial hyphen]).segments
      result.delete(h)
    end

  end
end
