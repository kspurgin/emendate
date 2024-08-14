# frozen_string_literal: true

module Emendate
  class Qualifier
    include Comparable

    attr_reader :type, :precision, :lexeme

    # @param type [:approximate, :approximate_and_uncertain, :inferred,
    #   :uncertain]
    # @param precision [:whole, :leftward, :rightward, :single_segment,
    #   :unknown]
    # @param lexeme [String, nil]
    def initialize(type:, precision:, lexeme: nil)
      @type = type
      @precision = precision
      @lexeme = clean_lexeme(lexeme)
    end

    def <=>(other)
      return unless other.is_a?(self.class)

      signature <=> other.signature
    end

    def hash = signature.hash

    def eql?(other) = self.class == other.class && self == other

    def to_s
      "#<#{self.class.name} type=#{type.inspect}, "\
        "precision=#{precision.inspect}, "\
        "lexeme=#{lexeme.inspect}>"
    end
    alias_method :inspect, :to_s

    def for_test
      "#{type}, #{precision}"
    end

    def signature = [type, precision, lexeme].join("|")

    private

    def clean_lexeme(str)
      return "" unless str

      str.gsub(/\p{Punct}/, "")
    end
  end
end
