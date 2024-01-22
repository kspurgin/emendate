# frozen_string_literal: true

module Emendate
  class OrdinalTranslator
    include Dry::Monads[:result]
    include Emendate::ResultEditable

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = Emendate::SegmentSet.new.copy(tokens)
    end

    def call
      if result[0].type == :ordinal_indicator
        result.warnings << "Ordinal indicator unexpectedly appears at "\
          "beginning of date string"
        collapse_token_pair_forward(result[0], result[1])
      end

      ois = result.when_type(:ordinal_indicator)
      return Success(result) if ois.empty?

      return Success(result) if ois.empty?

      ois.each do |oi|
        prev = previous(oi)
        unless prev.type == :number1or2
          result.warnings << "Ordinal indicator expected after :number1or2. "\
            "Found after :#{prev.type}"
        end
        collapse_token_pair_backward(prev, oi)
      end

      Success(result)
    end

    private

    attr_reader :result

    def previous(ord_ind)
      oi_ind = result.find_index(ord_ind)
      prev_ind = oi_ind - 1
      result[prev_ind]
    end
  end
end
