# frozen_string_literal: true

module Emendate
  class UntokenizableTagger
    attr_reader :result

    def initialize(str:)
      @result = Emendate::MixedSet.new
    end

    def tag
      result << Emendate::Segment.new(type: :untokenizable,
                                      lexeme: str,
                                      literal: str)
    end
  end
end
