# frozen_string_literal: true

module Emendate
  class UntokenizableTagger
    attr_reader :str, :result

    class << self
      def call(...)
        self.initialize(...).call
      end
    end

    def initialize(tokens:, str:)
      @tokens = tokens
      @str = str
      @result = Emendate::SegmentSets::MixedSet.new
    end

    def tag
      unless untokenizable?
        passthrough
        return
      end

      result << Emendate::DateTypes::Untokenizable.new(
        children: @tokens.segments, literal: str
      )
      result.warnings << "Untokenizable sequences: "\
        "#{untokenizable_strings.join('; ')}"
    end

    private

    def passthrough
      @result = Emendate::SegmentSets::MixedSet.new.copy(@tokens)
    end

    def untokenizable_strings
      @tokens.select{ |token| token.type == :unknown }.segments.map(&:lexeme)
    end

    def untokenizable?
      @tokens.types.any?(:unknown)
    end
  end
end
