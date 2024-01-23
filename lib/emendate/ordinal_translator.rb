# frozen_string_literal: true

module Emendate
  class OrdinalTranslator
    include Dry::Monads[:result]

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
        result.collapse_segment(result[0], :forward)
      end

      ois = result.when_type(:ordinal_indicator)
      return Success(result) if ois.empty?

      return Success(result) if ois.empty?

      ois.each do |oi|
        prev = result.previous_segment(oi)
        unless prev.type == :number1or2
          result.warnings << "Ordinal indicator expected after :number1or2. "\
            "Found after :#{prev.type}"
        end
        result.collapse_segment(oi, :backward)
      end

      Success(result)
    end

    private

    attr_reader :result
  end
end
