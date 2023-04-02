# frozen_string_literal: true

module Emendate
  class DateSegmenter
    include DateUtils
    include Dry::Monads[:result]

    class << self
      def call(...)
        self.new(...).call
      end
    end

    def initialize(tokens)
      @working = tokens.class.new.copy(tokens)
      @result = tokens.class.new.copy(tokens)
      result.clear
    end

    def call
      until working.empty?
        recursive_parse
      end
      working.copy(result)
      result.clear
      until working.empty?
        apply_partial_modifiers
      end

      working.copy(result)
      result.clear
      until working.empty?
        apply_switch_modifiers
      end

      if bce?
        apply_bce
      end

      Success(result)
    end

    private

    attr_reader :working, :result

    def bce?
      result.type_string.match?(/(?:year_date_type bce|bce year_date_type)/)
    end

    def apply_bce
      if result.type_string.match?(/year_date_type bce/)
        segments = result.extract(:year_date_type, :bce)
        year = segments[0]
        bce = segments[1]
      else
        segments = result.extract(:bce, :year_date_type)
        year = segments[1]
        bce = segments[0]
      end
      year.bce
      result.delete(bce)
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
      when :present
        :parse_present
      when :season
        :parse_date_parts
      when :year
        :parse_date_parts
      else
        :parse_non_date_part
      end
    end

    def apply_switch_modifiers
      return if working.empty?

      mod = switch_mod_function
      return if mod.nil?

      send(mod)
    end

    def switch_mod_function
      return nil if working.empty?

      case working.types.first
      when :after
        :mod_switch
      when :before
        :mod_switch
      else
        :passthrough_switch_mod
      end
    end

    def mod_switch
      switch = working.shift
      if current.kind_of?(Emendate::DateTypes::DateType)
        current.range_switch = switch.type.to_s
        result << current.prepend_source_token(switch)
        working.shift
      else
        result << switch
      end
      apply_switch_modifiers
    end

    def passthrough_switch_mod
      transfer_token
      apply_switch_modifiers
    end

    def apply_partial_modifiers
      return if working.empty?

      mod = partial_mod_function
      return if mod.nil?

      send(mod)
    end

    def partial_mod_function
      return nil if working.empty?

      case working.types.first
      when :partial
        :mod_partial
      else
        :passthrough_partial_mod
      end
    end

    def mod_partial
      partial = working.shift
      if current.kind_of?(Emendate::DateTypes::DateType)
        current.partial_indicator = partial.lexeme.strip.delete_suffix('-')
        result << current.prepend_source_token(partial)
        working.shift
      else
        result << partial
      end
      apply_partial_modifiers
    end

    def passthrough_partial_mod
      transfer_token
      apply_partial_modifiers
    end

    def parse_decade_date_part
      decade = working[0]
      if s_date?(decade)
        result << Emendate::DateTypes::Decade.new(literal: decade.literal,
                                                  decade_type: :plural,
                                                  sources: [decade])
      elsif uncertainty_date?(decade)
        result << Emendate::DateTypes::Decade.new(literal: decade.literal,
                                                  decade_type: :uncertainty_digits,
                                                  sources: [decade])
      end
      working.shift
      recursive_parse
    end

    def s_date?(segment)
      segment.sources.types.include?(:letter_s)
    end

    def uncertainty_date?(segment)
      segment.sources.types.include?(:uncertainty_digits)
    end

    def parse_millennium_date_part
      millennium = working[0]
      if s_date?(millennium)
        result << Emendate::DateTypes::Millennium.new(literal: millennium.literal,
                                                      millennium_type: :plural,
                                                      sources: [millennium])
      elsif uncertainty_date?(millennium)
        result << Emendate::DateTypes::Millennium.new(literal: millennium.literal,
                                                      millennium_type: :uncertainty_digits,
                                                      sources: [millennium])
      end
      working.shift
      recursive_parse
    end


    def parse_century_date_part
      cent = working[0]
      result << Emendate::DateTypes::Century.new(
        literal: century_literal(cent),
        century_type: century_type(cent),
        sources: [cent]
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
      elsif pieces.types.sort == %i[season year]
        result << create_year_season_datetype(pieces)
      elsif pieces.types.sort == %i[year]
        result << create_year_datetype(pieces)
      else
        fail(Emendate::UnsegmentableDatePatternError.new(pieces))
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
                                            sources: pieces.segments)
    end

    def create_year_month_datetype(pieces)
      month = pieces.when_type(:month)[0]
      year = pieces.when_type(:year)[0]
      Emendate::DateTypes::YearMonth.new(year: year.literal,
                                         month: month.literal,
                                         sources: pieces.segments)
    end

    def create_year_season_datetype(pieces)
      month = pieces.when_type(:season)[0]
      year = pieces.when_type(:year)[0]
      Emendate::DateTypes::YearSeason.new(year: year.literal,
                                          month: month.literal,
                                          sources: pieces.segments)
    end

    def create_year_datetype(pieces)
      year = pieces.when_type(:year)[0]
      Emendate::DateTypes::Year.new(literal: year.literal,
                                    sources: pieces.segments)
    end

    def consume_date_parts
      pieces = Emendate::SegmentSets::MixedSet.new
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
        result << Emendate::DateTypes::Year.new(
          literal: current.lexeme, sources: pieces
        )
      when :ym
        result << Emendate::DateTypes::YearMonth.new(
          year: year, month: month, sources: pieces
        )
      end
      working.delete(current)

      recursive_parse
    end

    def parse_present
      now = DateTime.now
      year = now.year
      month = now.month
      day = now.day

      result << Emendate::DateTypes::YearMonthDay.new(
        year: year, month: month, day: day, sources: [current]
      )
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
        result << Emendate::DateTypes::YearMonthDay.new(
          year: year, month: month, day: day, sources: pieces
        )
      when :long_year
        result << Emendate::DateTypes::Year.new(
          literal: current.lexeme, sources: pieces
        )
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
