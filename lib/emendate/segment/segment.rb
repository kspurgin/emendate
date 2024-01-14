# frozen_string_literal: true

require "forwardable"

module Emendate
  # Tokens, tagged date parts, tagged dates are subclasses of Segment
  class Segment
    attr_reader :type, :lexeme, :literal, :certainty, :digits, :location

    COLLAPSIBLE_TYPES = %i[space single_dot standalone_zero]

    # Segments having these types will return true for :date_part?
    DATE_PART_TYPES = %i[number1or2 number3 number4 number6 number8 s century
      uncertainty_digits era
      number_month month_alpha month_abbr_alpha
      year month season day]

    def initialize(**opts)
      @type = opts[:type]
      @lexeme = opts[:lexeme]
      @literal = opts[:literal] || default_literal
      @certainty = default_certainty
      @digits = nil
      @location = opts[:location]
      post_initialize(opts)
    end

    # @param val [Symbol]
    def add_certainty(val)
      certainty << val
      certainty.flatten!
    end

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

    # @return [TrueClass]
    def segment? = true

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

    private

    # subclasses can override this empty method
    def post_initialize(opts)
    end

    def default_certainty
      []
    end

    def default_literal
      nil
    end
  end
end
