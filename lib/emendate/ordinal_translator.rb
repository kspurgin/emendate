# frozen_string_literal: true

module Emendate
  class OrdinalTranslator
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = Emendate::SegmentSet.new.copy(tokens)
    end

    def call
      _d_handled = yield handle_letter_d

      if result[0].type == :ordinal_indicator
        result.warnings << "Ordinal indicator unexpectedly appears at "\
          "beginning of date string"
        result.collapse_segment(result[0], :forward)
      end

      ois = result.when_type(:ordinal_indicator)
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

    def handle_letter_d
      segs = result.when_type(:letter_d)
      return Success(result) if segs.empty?

      segs.each do |seg|
        next if result.index_of(seg) == 0
        previous = result.previous_segment(seg)
        next unless previous.number?

        result.collapse_segment(seg, :backward)
      end
      Success(result)
    end
  end
end
