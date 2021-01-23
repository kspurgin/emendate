# frozen_string_literal: true

module Emendate
  class Certainty

    attr_reader :orig, :result, :values

    def initialize(tokens:)
      @orig = tokens
      @result = tokens.clone
      @values = []
    end

    def check
      until done? do
        process_certainty
      end
      self
    end

    private

    def process_certainty
      case result.types
        in [:square_bracket_open, *remain, :square_bracket_close]
        process_supplied(remain)
        in [:approximate, *]
        process_approximate
        in [:c, *]
        process_approximate
        in [*, :question]
        process_questionable
      end
    end

    def process_questionable
      values << :questionable
      result.pop
    end
    
    def process_approximate
      values << :approximate
      result.shift
    end
    
    def process_supplied(remain)
      unless remain.include?(:square_bracket_open) || remain.include?(:square_bracket_close)
        values << :supplied
        result.shift
        result.pop
      end
    end
    
    def done?
      supplied_indicator? || approximate_indicator? || questionable_indicator? ? false : true
    end

    def supplied_indicator?
      case result.types
        in [:square_bracket_open, *remain, :square_bracket_close]
        remain.include?(:square_bracket_open) || remain.include?(:square_bracket_close) ? false : true
      else
        false
      end
    end

    def approximate_indicator?
      case result.types
        in [:approximate, *]
        true
        in [:c, *]
        true
      else
        false
      end
    end

    def questionable_indicator?
      case result.types
      in [*, :question]
        true
      else
        false
      end
    end
  end
end
