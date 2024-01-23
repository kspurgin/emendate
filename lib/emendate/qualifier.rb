# frozen_string_literal: true

module Emendate
  # @param type [:approximate, :approximate_and_uncertain, :inferred,
  #   :uncertain]
  # @param precision [:whole, :leftward, :rightward, :single_segment, :unknown]
  # @param lexeme [String]
  # @param sources [Array<Emendate::Segment>]
  Qualifier = Data.define(:type, :precision, :lexeme) do
    def initialize(type:, precision:, lexeme: "")
      super
    end

    def to_s
      "#<#{self.class.name} type=#{type.inspect}, "\
        "precision=#{precision.inspect}, "\
        "lexeme=#{lexeme.inspect}>"
    end
    alias_method :inspect, :to_s

    def for_test
      "#{type}, #{precision}"
    end
  end
end
