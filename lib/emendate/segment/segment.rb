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
    # @return [Symbol]
    attr_reader :type
    # @return [String, NilClass]
    attr_reader :lexeme
    # @return [Integer, Symbol, NilClass]
    attr_reader :literal
    # @return [Array<Symbol>]
    attr_reader :certainty
    # @return [Array<Segment>, Emendate::SegmentSets::SegmentSet, NilClass]
    attr_reader :sources
    # @return [Integer, NilClass]
    attr_reader :digits
    # @return [Location, NilClass]
    attr_reader :location

    # Segment types that can be collapsed without considering possible
    # meaning in the pattern.
    COLLAPSIBLE_TYPES = %i[space single_dot standalone_zero]

    # Segments having these types will return true for :date_part?
    DATE_PART_TYPES = %i[number1or2 number3 number4 number6 number8 s century
      uncertainty_digits era
      number_month month_alpha month_abbr_alpha
      year month season day]

    # @param type [Symbol]
    # @param lexeme [String, NilClass]
    # @param literal [Integer, Symbol, NilClass]
    # @param certainty [Array<Symbol>]
    # @param sources [Array<Segment>, Emendate::SegmentSets::SegmentSet,
    #   NilClass]
    # @param location [Location, NilClass]
    def initialize(type:, lexeme: nil, literal: nil, certainty: [],
      sources: nil, location: nil)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @certainty = certainty
      @sources = sources
      @digits = nil
      @location = location
    end

    # @param val [Symbol]
    def add_certainty(val)
      certainty << val
      certainty.flatten!
    end

    # Mainly used to clear the lexeme in dummy Segments used to standardize
    # formatting
    # @param val [String]
    def reset_lexeme(val = nil)
      @lexeme = val.to_s
    end

    # @return [Boolean]
    def collapsible? = COLLAPSIBLE_TYPES.include?(type)

    # @return [TrueClass, NilClass]
    def date_part?
      true if DATE_PART_TYPES.include?(type)
    end

    # @return [FalseClass]
    def date_type? = false

    # @return [TrueClass] when segment is a DateType or has type :and or :or
    # @return [FalseClass] otherwise
    def processed?
      true if date_type? || type == :or || type == :and
    end

    # @return [String]
    def to_s = "#{type} #{lexeme} #{literal}"

    # @deprecated Location functions are being removed
    def col
      return nil unless location

      location.col
    end

    # @deprecated Location functions are being removed
    def length
      return nil unless location

      location.length
    end
  end
end
