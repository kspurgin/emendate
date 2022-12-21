# frozen_string_literal: true

module Emendate
  class OrdinalTranslator
    include Dry::Monads[:result]

    class << self
      def call(...)
        self.new(...).call
      end
    end

    def initialize(tokens)
      @result = Emendate::SegmentSets::TokenSet.new.copy(tokens)
    end

    def call
      ois = result.when_type(:ordinal_indicator)
      return Success(result) if ois.empty?

      if result[0].type == :ordinal_indicator
        result.warnings << 'Ordinal indicator unexpectedly appears at beginning of date string'
        result.shift
        ois.shift
      end

      return Success(result) if ois.empty?

      ois.each do |oi|
        prev = previous(oi)
        unless prev.type == :number1or2
          result.warnings << "Ordinal indicator expected after :number1or2. Found after :#{prev.type}"
        end
        result.delete(oi)
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
