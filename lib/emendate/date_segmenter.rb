# frozen_string_literal: true

require_relative "result_editable"

module Emendate
  class DateSegmenter
    include DateUtils
    include Dry::Monads[:result]
    include Emendate::ResultEditable

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @working = tokens.class.new.copy(tokens)
      @result = tokens.class.new.copy(tokens)
      result.clear
    end

    def call
      recursive_parse until working.empty?

      %i[partial before after era_bce].each do |mod|
        working.copy(result)
        result.clear
        apply_modifiers(mod) until working.empty?
      end

      separators = result.select { |seg| %i[and or].include?(seg.type) }
      return Success(result) if separators.empty?

      if separators.map(&:type).uniq.length > 1
        return Failure(:multiple_date_separator_types)
      else
        transform_separators(separators)
      end

      Success(result)
    end

    private

    attr_reader :working, :result

    def recursive_parse
      return if working.empty?

      parser = parse_function
      return if parser.nil?

      parser.call
    end

    def parse_function
      return nil if working.empty?

      case working.types.first
      when :century
        proc { parse_century_date_part }
      when :day
        proc { parse_date_parts }
      when :decade
        proc { parse_decade_date_part }
      when :millennium
        proc { parse_millennium_date_part }
      when :month
        proc { parse_date_parts }
      when :number6
        proc { parse_yyyymm }
      when :number8
        proc { parse_yyyymmdd }
      when :present
        proc { parse_present }
      when :season
        proc { parse_season }
      when :year
        proc { parse_date_parts }
      else
        proc { parse_non_date_part }
      end
    end

    def apply_modifiers(type)
      return if working.empty?

      mod = mod_function(type)
      return if mod.nil?

      mod.call
    end

    def mod_function(type)
      return nil if working.empty?
      return proc { passthrough_mod(type) } if working.length < 2

      pair = working.first(2)
      if pair[0].date_type? && pair[1].type == type
        proc { apply_modifier(type, :backward) }
      elsif pair[0].type == type && pair[1].date_type?
        proc { apply_modifier(type, :forward) }
      else
        proc { passthrough_mod(type) }
      end
    end

    def apply_modifier(type, direction)
      case direction
      when :forward
        modifier = working[0]
        datetype = working[1]
      when :backward
        datetype = working[0]
        modifier = working[1]
      end

      addable = datetype.addable?(type)

      case direction
      when :forward
        if addable
          datetype.prepend_source_token(modifier)
        else
          add_as_unprocessable(modifier)
        end
        result << datetype
        working.shift(2)
      when :backward
        if addable
          datetype.append_source_token(modifier)
          result << datetype
          working.shift(2)
        else
          result << datetype
          working.shift
        end
      end

      apply_modifiers(type)
    end

    def add_as_unprocessable(modifier)
      result << Emendate::Segment.new(
        type: "unprocessable_#{modifier_type}", sources: [modifier]
      )
    end

    def passthrough_mod(type)
      transfer_token
      apply_modifiers(type)
    end

    def parse_decade_date_part
      result << Emendate::DateTypes::Decade.new(sources: [working[0]])
      working.shift
      recursive_parse
    end

    def parse_millennium_date_part
      result << Emendate::DateTypes::Millennium.new(sources: [working[0]])
      working.shift
      recursive_parse
    end

    def parse_century_date_part
      result << Emendate::DateTypes::Century.new(
        sources: [working[0]]
      )
      working.shift
      recursive_parse
    end

    def parse_season
      pieces = date_parts
      if one_winter?
        two_year_winter
      elsif pieces.types.sort == %i[season year]
        result << create_year_season_datetype(pieces)
        working.clear
        recursive_parse
      elsif working.types[0..1].sort == %i[season year] &&
          working.types[2] == :range_indicator
        result << create_year_season_datetype(
          Emendate::SegmentSet.new(segments: working.shift(2))
        )
        recursive_parse
      else
        raise Emendate::UnsegmentableDatePatternError, pieces
      end
    end

    def two_year_winter
      pos = result.length
      working[0..3].each { |seg| result << seg }
      working.shift(4)

      season = result[0 + pos]
      prev_yr = result[1 + pos]
      ri = result[2 + pos]
      year = result[3 + pos]

      [prev_yr, ri].each do |seg|
        replace_x_with_new(
          x: seg, new: Emendate::Segment.new(
            type: :dummy, lexeme: seg.lexeme, sources: [seg]
          )
        )
      end

      orig = result[Range.new(pos, pos + 3)]
      replace_segments_with_new(
        segments: orig,
        new: Emendate::DateTypes::YearSeason.new(
          year: year.literal,
          season: season.literal,
          sources: orig,
          include_prev_year: true
        )
      )
      recursive_parse
    end

    def one_winter?
      true if winter? &&
        followed_by_year_range? &&
        consecutive_years_in_range?
    end

    def winter?
      true if working[0].literal == 24
    end

    def followed_by_year_range?
      true if working[1..3].compact.map(&:type) == %i[year range_indicator year]
    end

    def consecutive_years_in_range?
      diff = working[3].literal - working[1].literal
      true if diff == 1
    end

    def parse_date_parts
      pieces = consume_date_parts

      datetype = case pieces.types.sort
      when %i[day month year]
        create_year_month_day_datetype(pieces)
      when %i[month year]
        create_year_month_datetype(pieces)
      when %i[season year]
        create_year_season_datetype(pieces)
      when %i[year]
        create_year_datetype(pieces)
      else
        raise Emendate::UnsegmentableDatePatternError, pieces
      end

      result << datetype
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
        season: month.literal,
        sources: pieces.segments)
    end

    def create_year_datetype(pieces)
      Emendate::DateTypes::Year.new(sources: pieces.segments)
    end

    def date_parts
      Emendate::SegmentSet.new(segments: working.date_parts)
    end

    def consume_date_parts
      pieces = Emendate::SegmentSet.new

      until working.empty? || !current.date_part?
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
      year = current.literal.to_s[0..3].to_i
      month = current.literal.to_s[4..5].to_i

      if !valid_year?(year) || !valid_month?(month)
        result.warnings << "#{current.lexeme} treated as a long year"
        date_type = :long_year
      else
        date_type = :ym
      end

      case date_type
      when :long_year
        yr = Emendate::Segment.new(type: :year, sources: [current])
        result << Emendate::DateTypes::Year.new(sources: [yr])
      when :ym
        yr = Emendate::Segment.new(
          type: :year, literal: year, sources: [current]
        )
        mth = Segment.new(type: :month, literal: month)
        result << Emendate::DateTypes::YearMonth.new(
          year: year, month: month, sources: [yr, mth]
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

      yr = Emendate::Segment.new(type: :year, literal: year, sources: [current])
      m = Emendate::Segment.new(type: :month, literal: month)
      d = Emendate::Segment.new(type: :day, literal: day)
      result << Emendate::DateTypes::YearMonthDay.new(
        year: year, month: month, day: day, sources: [yr, m, d]
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
        yr = Emendate::Segment.new(
          type: :year, literal: year, sources: [current]
        )
        mth = Segment.new(type: :month, literal: month)
        d = Segment.new(type: :day, literal: day)

        result << Emendate::DateTypes::YearMonthDay.new(
          year: year, month: month, day: day, sources: [yr, mth, d]
        )
      when :long_year
        result << Emendate::DateTypes::Year.new(sources: pieces)
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

    def transform_separators(segments)
      add_set_type(segments)
      segments.each { |seg| transform_separator(seg) }
    end

    def add_set_type(segments)
      segtype = segments.first.type
      set_type = (segtype == :or) ? :alternate : :inclusive
      result.add_set_type(set_type)
    end

    def transform_separator(segment)
      replace_x_with_derived_new_type(x: segment, type: :date_separator)
    end
  end
end
