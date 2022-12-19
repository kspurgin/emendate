# frozen_string_literal: true

module Emendate
  class UntokenizableTagger
    include Dry::Monads[:result]

    class << self
      def call(...)
        self.new(...).call
      end
    end

    def initialize(tokens)
      @tokens = tokens
    end

    def call
      return Success(tokens) unless untokenizable?

      result = Emendate::SegmentSets::MixedSet.new
      result << Emendate::DateTypes::Untokenizable.new(
        children: tokens.segments
      )
      result.warnings << "Untokenizable sequences: "\
        "#{untokenizable_strings.join('; ')}"
      Failure(result)
    end

    private

    attr_reader :tokens

    def untokenizable_strings
      tokens.select{ |token| token.type == :unknown }.segments.map(&:lexeme)
    end

    def untokenizable?
      tokens.types.any?(:unknown)
    end
  end
end
