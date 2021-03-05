# frozen_string_literal: true

module Emendate

  class DateSegmenter
    include DateUtils

    attr_reader :options, :result
    attr_accessor :working

    def initialize(tokens:, options: {})
      @options = options
      @working = Emendate::MixedSet.new.copy(tokens)
      @result = Emendate::MixedSet.new.copy(tokens)
      result.clear
    end

    def segment
      until working.empty?
        recursive_parse
      end

      working.copy(result)
      result.clear
      until working.empty?
        apply_modifiers
      end
      result
    end

    private

    def apply_modifiers
      return if working.empty?
      mod = mod_function
      return if mod.nil?
      send(mod)
    end

    def mod_function
      return nil if working.empty?
      case working.types.first
      when :partial
        :mod_partial
      when :after
        :mod_switch
      when :before
        :mod_switch
      else
        :passthrough_mod
      end
    end

    def mod_switch
      switch = working.shift
      if current.kind_of?(Emendate::DateTypes::DateType)
        current.range_switch = switch.lexeme
        result << current
        working.shift
      else
        result << switch
      end
      apply_modifiers
    end

    def mod_partial
      partial = working.shift
      if current.kind_of?(Emendate::DateTypes::DateType)
        current.partial_indicator = partial.lexeme
        result << current
        working.shift
      else
        result << partial
      end
      apply_modifiers
    end

    def passthrough_mod
      transfer_token
      apply_modifiers
    end

    def recursive_parse
      return if working.empty?
      parser = parse_function
      return if parser.nil?

      send(parser)
    end

    def parse_function
      return nil if working.empty?

      case working.types.first
      when :century
        :parse_century_date_part
      when :day
        :parse_date_parts
      when :decade
        :parse_decade_date_part
      when :millennium
        :parse_millennium_date_part
      when :month
        :parse_date_parts
      when :number6
        :parse_yyyymm
      when :number8
        :parse_yyyymmdd
      when :year
        :parse_date_parts
      else
        :parse_non_date_part
      end
    end

    def parse_decade_date_part
      decade = working[0]
      if s_date?(decade)
        result << Emendate::DateTypes::Decade.new(literal: decade.literal,
                                                  decade_type: :plural,
                                                  children: [decade])
      elsif uncertainty_date?(decade)
        result << Emendate::DateTypes::Decade.new(literal: decade.literal,
                                                  decade_type: :uncertainty_digits,
                                                  children: [decade])
      end
      working.shift
      recursive_parse
    end

    def s_date?(segment)
      segment.sources.types.include?(:letter_s) ? true : false
    end

    def uncertainty_date?(segment)
      segment.sources.types.include?(:uncertainty_digits) ? true : false
    end

    def parse_millennium_date_part
      millennium = working[0]
      if s_date?(millennium)
        result << Emendate::DateTypes::Millennium.new(literal: millennium.literal,
                                                      millennium_type: :plural,
                                                      children: [millennium])
      elsif uncertainty_date?(millennium)
        result << Emendate::DateTypes::Millennium.new(literal: millennium.literal,
                                                      millennium_type: :uncertainty_digits,
                                                      children: [millennium])
      end
      working.shift
      recursive_parse
    end


    def parse_century_date_part
      cent = working[0]
      result << Emendate::DateTypes::Century.new(
        literal: century_literal(cent),
        century_type: century_type(cent),
        children: [cent]
      )
      working.shift
      recursive_parse
    end

    def century_literal(datepart)
      if datepart.lexeme[-1] == 's'
        datepart.literal.to_s[0..-3].to_i
      else
        datepart.literal
      end
    end

    def century_type(datepart)
      if datepart.lexeme[-1] == 's'
        :plural
      elsif datepart.lexeme[-1].match?(/[ux]/)
        :uncertainty_digits
      else
        :name
      end
    end

    def parse_date_parts
      pieces = consume_date_parts
        if pieces.types.sort == %i[day month year]
          result << create_year_month_day_datetype(pieces)
        elsif pieces.types.sort == %i[month year]
          result << create_year_month_datetype(pieces)
        elsif pieces.types.sort == %i[year]
          result << create_year_datetype(pieces)
        end

        recursive_parse
    end

    def create_year_month_day_datetype(pieces)
      day = pieces.when_type(:day)[0]
      month = pieces.when_type(:month)[0]
      year = pieces.when_type(:year)[0]
      Emendate::DateTypes::YearMonthDay.new(year: year.literal,
                                            month: month.literal,
                                            day: day.literal,
                                            children: pieces.segments)
    end

    def create_year_month_datetype(pieces)
      month = pieces.when_type(:month)[0]
      year = pieces.when_type(:year)[0]
      Emendate::DateTypes::YearMonth.new(year: year.literal,
                                         month: month.literal,
                                         children: pieces.segments)
    end

    def create_year_datetype(pieces)
      year = pieces.when_type(:year)[0]
      Emendate::DateTypes::Year.new(literal: year.literal,
                                    children: pieces.segments)
    end

    def consume_date_parts
      pieces = Emendate::MixedSet.new
      until working.empty? || current.date_part? == false
        pieces << current
        working.delete(current)
      end
      pieces
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
      transfer_token
      recursive_parse
    end

    def parse_non_date_part
      transfer_token
      recursive_parse
    end

    def parse_yyyymm
      pieces = []
      year = current.lexeme[0..3]
      month = current.lexeme[4..5]

      if !valid_year?(year) || !valid_month?(month)
        result.warnings << "#{current.lexeme} treated as a long year"
        date_type = :long_year
      else
        date_type = :ym
      end
      pieces << current

      case date_type
      when :long_year
        result << Emendate::DateTypes::Year.new(literal: current.lexeme, children: pieces)
      when :ym
        result << Emendate::DateTypes::YearMonth.new(year: year, month: month, children: pieces)
      end
      working.delete(current)

      recursive_parse
    end

    def parse_yyyymmdd
      pieces = []
      year = current.lexeme[0..3]
      month = current.lexeme[4..5]
      day = current.lexeme[6..7]

      begin
        Date.new(year.to_i, month.to_i, day.to_i)
      rescue Date::Error
        result.warnings << "#{current.lexeme} treated as a long year"
        date_type = :long_year
      else
        date_type = :ymd
      end
        pieces << current

        case date_type
        when :ymd
          result << Emendate::DateTypes::YearMonthDay.new(year: year, month: month, day: day, children: pieces)
        when :long_year
          result << Emendate::DateTypes::Year.new(literal: current.lexeme, children: pieces)
        end
        working.delete(current)
        recursive_parse
    end

    def transfer_token(token = current)
      result << token
      working.delete(token)
    end

    def current
      working[0]
    end
  end
end
