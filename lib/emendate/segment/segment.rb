# frozen_string_literal: true

require "forwardable"

module Emendate
  # Represents elemental parts of a date string.
  #
  # Initially a string is lexed into very basic Segments with types
  # like :space, :number4 (a 4-digit number sequence), or :s (the
  # letter "s").
  #
  # A Segment initialized with other Segments as its sources can
  # derive attributes from its sources. Segments get combined this way
  # to simplify the date patterns for further processing. That is,
  # eventually "2-20-2010" will become three Segments with the types
  # `:month` (lexeme = "2-"), `:day` (lexeme = "20-"), and `:year`
  # (lexeme = 2010).
  #
  # Those three Segments can be combined into a YearMonthDay DateType.
  #
  # The lexeme of a Segment should always equal the substring of the
  # original string that is represented by the Segment. We sometimes
  # create dummy Segments for this reason. For example, given original
  # string: "Feb. 05 or 15, 2010", the SegmentSet after the format
  # standardization step will look like:
  #
  #    | segment type | lexeme  | literal |
  #    |--------------+---------+---------|
  #    | month        | "Feb. " |       2 |
  #    | day          | "05 "   |       5 |
  #    | year         |         |    2010 |
  #    | or           | "or "   |         |
  #    | month        |         |       2 |
  #    | day          | "15, "  |      15 |
  #    | year         | "2010"  |    2010 |
  #
  # The literal should be the numeric representation of the lexeme/type.
  class Segment
    include Subsourceable

    # @return [Symbol]
    attr_reader :type
    # @return [String, NilClass]
    attr_reader :lexeme
    # @return [Integer, Symbol, NilClass]
    attr_reader :literal
    # @return [Array<Emendate::Qualifier>]
    attr_reader :qualifiers
    # @return [Emendate::SegmentSet, NilClass]
    attr_reader :sources
    # @return [Integer, NilClass]
    attr_reader :digits

    # Segment types that can be collapsed without considering possible
    # meaning in the pattern.
    COLLAPSIBLE_TYPES = %i[space single_dot standalone_zero]

    # List of initial/most granular types of segments that should be considered
    # potentially part of an actual date value (e.g. not a date qualifier,
    # date separator, partial indicator, era, punctuation, etc.)
    INITIAL_DATE_PARTS = %i[number1or2 number3 number4 number6 number8
      letter_s uncertainty_digits month_alpha season]

    # List of segment types indicating the segment represents a known date part
    TAGGED_DATE_PARTS = %i[millennium century decade year month season day]

    # All segments types considered to be date parts
    DATE_PART_TYPES = [INITIAL_DATE_PARTS, TAGGED_DATE_PARTS].flatten

    # @param type [Symbol]
    # @param lexeme [String, NilClass]
    # @param literal [Integer, Symbol, NilClass]
    # @param qualifiers [Array<Emendate::Qualifier>]
    # @param sources [Array<Segment>, Emendate::SegmentSet,
    #   NilClass]
    def initialize(type:, lexeme: nil, literal: nil, qualifiers: [],
      sources: nil)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @qualifiers = qualifiers
      @sources = get_sources(sources)
      @digits = nil
      derive_values if @sources
    end

    # @param qual [Emendate::Qualifier]
    def add_qualifier(qual)
      qualifiers << qual
    end

    # Mainly used to clear the lexeme in dummy Segments used to standardize
    # formatting
    # @param val [String]
    def reset_lexeme(val = nil)
      @lexeme = val.to_s
      self
    end

    # @return [Boolean]
    def collapsible? = COLLAPSIBLE_TYPES.include?(type)

    # @return [TrueClass, NilClass]
    def date_part?
      true if DATE_PART_TYPES.include?(type)
    end

    # This method exists so that Segments and date type classes can
    # coexist in SegmentSets
    # @return [FalseClass]
    def date_type? = false

    # @return [TrueClass] if type starts with `number`
    # @return [FalseClass] otherwise
    def number? = type.to_s.start_with?("number")

    # @return [TrueClass] when segment is a DateType or has type :and or :or
    # @return [FalseClass] otherwise
    def processed?
      true if date_type? || type == :or || type == :and
    end

    def segment? = true

    # @return [String]
    def to_s
      arr = ["#<#{self.class.name}:#{object_id} "\
        "@type: #{type.inspect}, "\
        "@lexeme: #{lexeme.inspect}, "\
        "@literal: #{literal.inspect}, "\
        "@digits: #{digits.inspect}, "]
      arr << if sources
        "@sources: #{sources.types.inspect}, "
      else
        "@sources: #{sources.inspect}, "
      end
      arr << "@qualifiers: #{qualifiers.inspect}>"
      arr.join("")
    end
    alias_method :inspect, :to_s

    private

    def get_sources(sources)
      return nil if sources.nil? || sources.empty?

      segset = Emendate::SegmentSet.new

      srcs = if sources.respond_to?(:segments)
        sources.segments
      else
        sources
      end

      srcs.each { |src| segset << src }
      segset
    end

    def derive_values
      (sources.length == 1) ? derive_from_single_val : derive_from_multiple_vals
    end

    def derive_from_single_val
      src = sources[0]
      @lexeme = src.lexeme if lexeme.nil?
      @literal = src.literal if literal.nil?
      @qualifiers = src.qualifiers if qualifiers.empty?
      @digits = src.digits
    end

    def derive_from_multiple_vals
      @lexeme = sources.map(&:lexeme).join("") if lexeme.nil?
      @literal = derive_literal if literal.nil?
      @qualifiers = sources.map(&:qualifiers).flatten.uniq
      @digits = sources.map(&:digits).compact.sum
    end

    def derive_literal
      literal = sources.map(&:literal).compact
      return nil if literal.empty?

      if literal.any? { |val| val.is_a?(Integer) } &&
          literal.any? { |val| val.is_a?(Symbol) }
        raise Emendate::DerivedSegmentError.new(
          sources, "Cannot derive literal from mixed Integers and Symbols"
        )
      elsif literal.all? { |val| val.is_a?(Integer) }
        literal.select { |val| val.is_a?(Integer) }
          .join("")
          .to_i
      elsif literal.all? { |val| val.is_a?(Symbol) }
        syms = literal.select { |val| val.is_a?(Symbol) }
        case syms.length
        when 1
          syms[0]
        else
          raise Emendate::DerivedSegmentError.new(
            sources, "Cannot derive literal from multiple symbols"
          )
        end
      else
        raise Emendate::DerivedSegmentError.new(
          sources, "Cannot derive literal for unknown reason"
        )
      end
    end
  end
end
