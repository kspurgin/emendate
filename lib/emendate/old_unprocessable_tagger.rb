# frozen_string_literal: true

module Emendate
  class OldUnprocessableTagger
    attr_reader :str, :result

    Patterns = [
      /^Y-\d+$/,
      /XXXX-\d{2}-XX/,
      /\dXXX-XX/,
      /\dXXX-\d{2}/,
      /\d{2}XX-\d{2}-\d{2}/,
      /\d{3}X-\d{2}-\d{2}/,
      /^\d{3,4}S\d+$/,
      /\d{4}-\d{2}-XX/
    ]
    Re = Regexp.union(Patterns)

    def initialize(tokens:, str:)
      @tokens = tokens
      @str = str
      @result = Emendate::SegmentSets::MixedSet.new
    end

    def tag
      unless str.match?(Re)
        passthrough
        return
      end

      result << Emendate::DateTypes::Unprocessable.new(children: @tokens.segments, literal: str)
      result.warnings << 'Unprocessable string'

    end

    private

    def passthrough
      @result = Emendate::SegmentSets::MixedSet.new.copy(@tokens)
    end
  end
end
