# frozen_string_literal: true

module Emendate
  # Returns a single {Emendate::DateTypes::Unprocessable} if date string
  #   matches a known unsupported pattern
  class UnprocessableTagger
    include Dry::Monads[:result]

    class << self
      def call(...)
        new(...).call
      end
    end

    PATTERNS = [
      /^y-\d+$/,
      /xxxx-\d{2}-xx/,
      /\dxxx-xx/,
      /\dxxx-\d{2}/,
      /\d{2}xx-\d{2}-\d{2}/,
      /\d{3}x-\d{2}-\d{2}/,
      /^\d{3,4}S\d+$/,
      /\d{4}-\d{2}-xx/
    ]
    Re = Regexp.union(PATTERNS)

    def initialize(tokens)
      @tokens = tokens
      @str = tokens.orig_string.downcase
    end

    def call
      return(Success(tokens)) unless str.match?(Re)

      result = tokens.class.new.copy(tokens)
      result.clear
      result << Emendate::DateTypes::Error.new(
        error_type: :unprocessable,
        sources: tokens
      )
      result.warnings << "Unprocessable string"
      Failure(result)
    end

    private

    attr_reader :tokens, :str
  end
end
