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
      elsif unknown_and_collapsible?
        collapse_collapsible
      else
        Success(tokens)
      end
    end

    private

    attr_reader :tokens, :result

    def whole_known_unknown?
      unknowns.length == 1 && tokens.length == 1
    end

    def question_at_end_of_string?
      tokens.type_string
        .match?(/(?:range_indicator|hyphen) question$/)
    end

    def unknown_and_collapsible?
      usegs = unknowns
      return false unless usegs.length == 1

      all_else_collapsible?(usegs[0])
    end

    def unknown_types = %i[no_date question unknown_date uncertainty_digits]

    def unknowns = tokens.select { |seg| unknown_types.include?(seg.type) }

    def return_unknown_date_type
      result.clear
      category = case tokens[0].type
      when :no_date
        :no_date
      else
        :unknown_date
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

    def all_else_collapsible?(useg)
      remain = tokens.segments - [useg]
      remain.all? { |seg| seg.collapsible? }
    end

    def collapse_collapsible
      Emendate::TokenCollapser.call(tokens)
        .fmap do |res|
          @tokens = res
          call
        end
      Failure(result)
    end
  end
end
