# frozen_string_literal: true

module Emendate
  class UnprocessableTagger
    include Dry::Monads[:result]

    class << self
      def call(...)
        self.new(...).call
      end
    end

    Patterns = [
      /^y-\d+$/,
      /xxxx-\d{2}-xx/,
      /\dxxx-xx/,
      /\dxxx-\d{2}/,
      /\d{2}xx-\d{2}-\d{2}/,
      /\d{3}x-\d{2}-\d{2}/,
      /^\d{3,4}S\d+$/,
      /\d{4}-\d{2}-xx/
    ]
    Re = Regexp.union(Patterns)

    def initialize(tokens)
      @tokens = tokens
      @str = tokens.segments
        .map(&:lexeme)
        .join
    end

    def call
      return(Success(tokens)) unless str.match?(Re)

      result = Emendate::SegmentSets::MixedSet.new
      result << Emendate::DateTypes::Unprocessable.new(
        children: tokens.segments
      )
      result.warnings << 'Unprocessable string'
      Failure(result)
    end

    private

    attr_reader :tokens, :str
  end
end
