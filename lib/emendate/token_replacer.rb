# frozen_string_literal: true

require 'emendate/result_editable'

module Emendate
  class TokenReplacer
    include Dry::Monads[:result]
    include ResultEditable

    class << self
      def call(...)
        self.new(...).call
      end
    end

    def initialize(tokens)
      @result = Emendate::SegmentSets::TokenSet.new.copy(tokens)
    end

    def call
      return Success(result) unless replaceable?

      result.select{ |token| replacements.key?(token.type) }
        .map{ |source| replace_x_with_derived_new_type(
          x: source,
          type: replacements[source.type])
        }
      Success(result)
    end

    private

    attr_reader :result

    def replaceable?
      result.types.intersect?(replacements.keys)
    end

    def replacements
      {
        about: :approximate,
        circa: :approximate
      }
    end
  end
end
