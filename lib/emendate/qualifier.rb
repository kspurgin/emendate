# frozen_string_literal: true

module Emendate
  # @param type [:approximate, :approximate_and_uncertain, :inferred,
  #   :uncertain]
  # @param precision [:whole, :leftward, :single_segment, :unknown]
  # @param lexeme [String]
  # @param sources [Array<Emendate::Segment>]
  Qualifier = Data.define(:type, :precision, :lexeme, :sources) do
    def initialize(type:, precision:, lexeme: "", sources: [])
      super
    end
  end
end
