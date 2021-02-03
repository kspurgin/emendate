# frozen_string_literal: true

module Emendate
  class UnexpectedInitialOrdinalError < StandardError; end
  class UnexpectedOrdinalError < StandardError; end
  
  class OrdinalTranslator
    attr_reader :orig, :result, :options
    attr_accessor :this_t
    def initialize(tokens:, options: {})
      @orig = tokens
      @result = Emendate::TokenSet.new
      @this_t = 0
      @options = options
    end

    def translate
      orig.each do |t|
        if t.type == :ordinal_indicator
          raise Emendate::UnexpectedInitialOrdinalError.new if this_t == 0
          prev_type = previous.type
          unless prev_type == :number1or2
            raise Emendate::UnexpectedOrdinalError.new("Ordinal indicator expected after :number1or2. Found after :#{prev_type}")
          end
        else
          result << t
        end
        @this_t += 1
      end
      result
    end

    private

    def previous
      orig[this_t - 1]
    end

  end
end
