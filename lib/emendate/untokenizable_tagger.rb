# frozen_string_literal: true

module Emendate
  class UntokenizableTagger
    include Dry::Monads[:result]

    attr_reader :result

    class << self
      def call(...)
        self.new(...).call
      end
    end

    def initialize(tokens:)
      @tokens = tokens
    end

    def call
      unless untokenizable?
        passthrough
        return Success(result)
      end

      @result = Emendate::SegmentSets::MixedSet.new
      result << Emendate::DateTypes::Untokenizable.new(
        children: tokens.segments,
        lexeme: tokens.segments.map(&:lexeme).join
      )
      result.warnings << "Untokenizable sequences: "\
        "#{untokenizable_strings.join('; ')}"
      Success(result)
    end

    private

    attr_reader :tokens

    def passthrough
      @result = tokens
    end

    def untokenizable_strings
      tokens.select{ |token| token.type == :unknown }.segments.map(&:lexeme)
    end

    def untokenizable?
      tokens.types.any?(:unknown)
    end
  end
end
