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
      @result = tokens.class.new.copy(tokens)
    end

    def call
      if known_unknown?
        return_unknown_date_type
      elsif end_of_range_unknown?
        replace_question_with_unknown
      else
        return Success(tokens)
      end
    end

    private

    attr_reader :tokens, :result

    def known_unknown?
      tokens.types == [:unknown_date]
    end

    def end_of_range_unknown?
      tokens.type_string
        .match?(/(?:range_indicator|hyphen) question$/)
    end

    def return_unknown_date_type
      result.clear
      result << Emendate::DateTypes::KnownUnknown.new(
        sources: tokens
      )
      Failure(result)
    end

    def replace_question_with_unknown
      question = result.pop
      result << Emendate::DerivedToken.new(
        type: :unknown_date,
        sources: [question]
      )
      return Success(result)
    end
  end
end
