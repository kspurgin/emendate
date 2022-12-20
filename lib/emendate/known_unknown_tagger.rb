# frozen_string_literal: true

module Emendate
  class KnownUnknownTagger
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
      return Success(tokens) unless known_unknown?

      result = Emendate::SegmentSets::MixedSet.new(
        string: tokens.orig_string
      )
      result << Emendate::DateTypes::KnownUnknown.new(
        lexeme: known_unknown_date_value
      )
      Failure(result)
    end

    private

    attr_reader :tokens

    def known_unknown_date_value
      return tokens.orig_string if Emendate.options.unknown_date_output == :orig

      Emendate.options.unknown_date_output_string
    end

    def known_unknown?
      tokens.types == [:unknown_date]
    end
  end
end
