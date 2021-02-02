# frozen_string_literal: true

module Emendate

  class DateSegmenter
    include DateUtils
    
    attr_reader :options, :orig, :result
    attr_accessor :working

    DATESEP = %i[hyphen slash].freeze

    def initialize(tokens:, options: {})
      @options = options
      @orig = tokens
      @working = orig.clone
      @result = Emendate::TokenSet.new
    end

    def segment
      until working.empty?
        #byebug
        recursive_parse
      end
      result
    end

    private

    def recursive_parse
      parser = parse_function
      if parser.nil?
        #unrecognized_token_error
        return
      end

      send(parser)
    end

    def parse_function
      return nil if working.empty?
      return :parse_uncertainty_digits if working.date_part_types[1] == :parse_uncertainty_digits
      
      case working.types.first
      when :number6
        :parse_starting_yyyymm
      when :number8
        :parse_starting_yyyymmdd
      when :number4
        :parse_starting_year
      when :number3
        :parse_starting_year
      when :number1or2
        :parse_starting_one_or_two_digit
      when :number_month
        :parse_starting_month
      else
        :parse_non_date_part
      end
    end

    def parse_function_for_one_or_two_digit_start
      return nil if working.empty?
      case working.date_part_types
      in [:number1or2, :century, *]
      :parse_named_century
      in [:number1or2, :number1or2, :century, *]
      :parse_named_centuries
      in [:number1or2, :number1or2, :number1or2, *]
      :parse_mdy_all_two_digits
      else
        :passthrough
      end
    end

    def parse_mdy_all_two_digits
      pieces = []
      pieces << consume_non_date_parts
      part1 = current
      pieces << part1
      working.delete(part1)
      pieces << consume_non_date_parts
      part2 = current
      pieces << part2
      working.delete(part2)
      pieces << consume_non_date_parts
      year = current
      pieces << year
      working.delete(year)
    end
    
    def parse_named_century
      cent = working[0]
      indicator = working[1]
      pieces = [cent, indicator]
      result << Emendate::DateTypes::Century.new(century: cent.literal, century_type: :name, children: pieces)
      working.delete(cent)
      working.delete(indicator)
    end

    def parse_named_centuries
      pieces = []
      cent1 = working[0]
      pieces << cent1
      working.delete(cent1)
      pieces << consume_non_date_parts
      result << Emendate::DateTypes::Century.new(century: cent1.literal, century_type: :name, children: pieces.flatten)

      pieces = []
      cent2 = working[0]
      indicator = working[1]
      result << Emendate::DateTypes::Century.new(century: cent2.literal, century_type: :name, children: [cent2, indicator])
      working.delete(cent2)
      working.delete(indicator)
    end

    def consume_non_date_parts
      pieces = []
      until current.is_a?(Emendate::NumberToken)
        pieces << current
        working.delete(current)
      end
      pieces
    end
    
    def passthrough
      continue_parse
    end
    
    def parse_non_date_part
      transfer_token
      return if nxt.nil?
      recursive_parse
    end
    
    def parse_starting_year
    end

    def parse_starting_one_or_two_digit
      parser = parse_function_for_one_or_two_digit_start
      if parser.nil?
        #unrecognized_token_error
        return
      end
      send(parser)
    end
    
    def parse_starting_yyyymm
      pieces = []
      year = current.lexeme[0..3]
      month = current.lexeme[4..5]

      if !valid_year?(year) || !valid_month?(month)
        continue_parse
      else
        pieces << current
      end

      return if pieces.empty?

      if nxt.nil?
        result << Emendate::DateTypes::YearMonth.new(year: year, month: month, children: pieces)
        working.delete(current)
      else
        continue_parse
      end
    end

    def parse_starting_yyyymmdd
      pieces = []
      year = current.lexeme[0..3]
      month = current.lexeme[4..5]
      day = current.lexeme[6..7]

      begin
        Date.new(year.to_i, month.to_i, day.to_i)
      rescue Date::Error
        continue_parse
      else
        pieces << current
      end

      return if pieces.empty?

      if nxt.nil?
        result << Emendate::DateTypes::YearMonthDay.new(year: year, month: month, day: day, children: pieces)
        working.delete(current)
      else
        continue_parse
      end
    end

    def continue_parse
      transfer_token
      recursive_parse
    end
   

    def transfer_token(token = current)
      result << token
      working.delete(token)
    end

    def determine_post_year_parsing_function
      if current.type == :number1or2 && valid_month?(current.lexeme)
        :parse_year_month
      elsif current.type == :number1or2 && valid_season?(current.lexeme)
        :parse_year_season
      end
    end
    
    def previous
      result[-1]
    end

    def current
      working[0]
    end

    def nxt
      working[1]
    end

    def nxt_sep?
      DATESEP.include?(nxt.type)
    end
        
    # def consume(offset = 1)
    #   t = lookahead(offset)
    #   self.next_t += offset
    #   t
    # end

    # def lookahead(offset = 1)
    #   lookahead_t = (next_t - 1) + offset
    #   return nil if lookahead_t < 0 || lookahead_t >= orig.length

    #   orig[lookahead_t]
    # end

    # def pending_tokens?
    #   next_t < orig.length
    # end
  end
end
