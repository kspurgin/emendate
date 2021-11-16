# frozen_string_literal: true

module Emendate
  class KnownUnknownTagger
    attr_reader :str, :result

    def initialize(tokens:, str:)
      @tokens = tokens
      @str = str
      @result = Emendate::SegmentSets::MixedSet.new
    end

    def tag
      unless known_unknown?
        passthrough
        return
      end
      
      result << Emendate::DateTypes::KnownUnknown.new(lexeme: str)
    end

    private

    def passthrough
      @result = Emendate::SegmentSets::MixedSet.new.copy(@tokens)
    end
    
    def known_unknown?
      @tokens.types == [:unknown_date]
    end
  end
end
