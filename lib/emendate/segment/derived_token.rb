# frozen_string_literal: true

require "emendate/segment/segment"
require "emendate/segment/derived_segment"

module Emendate
  # A token derived from another Token or Tokens
  # Usage:
  # rubocop:todo Layout/LineLength
  # Emendate::DerivedToken.new(type: :token_type, sources: [array of source tokens])
  # rubocop:enable Layout/LineLength
  class DerivedToken < Emendate::Segment
    include DerivedSegment

    # @param type [Symbol]
    # @param lexeme [String, NilClass]
    # @param literal [Integer, Symbol, NilClass]
    # @param sources [Array<Segment>, Emendate::SegmentSets::SegmentSet,
    #   NilClass]
    # @raise Emendate::DeriveFromNothingError if initialized with nil or
    #   empty sources
    def initialize(type:, sources:, lexeme: nil, literal: nil)
      super

      raise Emendate::DeriveFromNothingError if sources.nil? || sources.empty?
      derive
    end
  end
end
