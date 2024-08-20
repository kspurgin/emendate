# frozen_string_literal: true

module Emendate
  class KnownUnknownTagger
    include Dry::Monads[:result]

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @tokens = tokens
      @result = tokens.class.new.copy(tokens)
    end

    def call
      if whole_known_unknown?
        return_unknown_date_type
      elsif question_at_end_of_string?
        replace_question_with_unknown
      else
        Success(tokens)
      end
    end

    private

    attr_reader :tokens, :result

    def whole_known_unknown?
      tokens.types == [:no_date] ||
        tokens.types == [:unknown_date] ||
        tokens.types == [:question]
    end

    def question_at_end_of_string?
      tokens.type_string
        .match?(/(?:range_indicator|hyphen) question$/)
    end

    def return_unknown_date_type
      result.clear
      category = if tokens[0].type == :question
        :unknown_date
      else
        tokens[0].type
      end
      result << Emendate::DateTypes::KnownUnknown.new(
        sources: tokens, category: category
      )
      Failure(result)
    end

    def replace_question_with_unknown
      question = result.pop
      result << Emendate::Segment.new(
        sources: [question], type: :unknown_date
      )
      Success(result)
    end
  end
end
