# frozen_string_literal: true

module Emendate
  class KnownUnknownTagger
    attr_reader :result

    def initialize(tokens:, str:, options:)
      @tokens = tokens
      @str = str
      @options = options
      @result = Emendate::SegmentSets::MixedSet.new
    end

    def tag
      unless known_unknown?
        passthrough
        return
      end
      
      result << Emendate::DateTypes::KnownUnknown.new(lexeme: known_unknown_date_value)
      result
    end

    private

    attr_reader :tokens, :str, :options
    
    def known_unknown_date_value
      return str if options.unknown_date_output == :orig

      options.unknown_date_output_string
    end
    
    def passthrough
      @result = Emendate::SegmentSets::MixedSet.new.copy(tokens)
    end
    
    def known_unknown?
      tokens.types == [:unknown_date]
    end
  end
end
