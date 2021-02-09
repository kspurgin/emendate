# frozen_string_literal: true

module Emendate
  class OrdinalTranslator
    attr_reader :result, :options
    def initialize(tokens:, options: {})
      @result = Emendate::TokenSet.new.copy(tokens)
      @options = options
    end

    def translate
      ois = result.when_type(:ordinal_indicator)
      return result if ois.empty?

      if result[0].type == :ordinal_indicator
        result.warnings << 'Ordinal indicator unexpectedly appears at beginning of date string'
        result.shift
        ois.shift
      end

      return result if ois.empty?
      
      ois.each do |oi|
        prev = previous(oi)
        unless prev.type == :number1or2
          result.warnings << "Ordinal indicator expected after :number1or2. Found after :#{prev.type}"
        end
        result.delete(oi)
      end
      
      result
    end

    private

    def previous(oi)
      oi_ind = result.find_index(oi)
        prev_ind = oi_ind - 1
        result[prev_ind]
    end
  end
end
