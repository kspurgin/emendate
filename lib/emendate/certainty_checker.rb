# frozen_string_literal: true

module Emendate
  class CertaintyChecker

    attr_reader :orig, :result, :options

    def initialize(tokens:, options: {})
      @orig = tokens
      @result = tokens.clone
      @options = options
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
        process_square_brackets(remain)
        in [:curly_bracket_open, *remain, :curly_bracket_close]
        process_curly_brackets(remain)
        in [:approximate, *]
        process_approximate
        in [:letter_c, *]
        process_approximate
        in [*, :question]
        process_uncertain
      end
    end

    def process_uncertain
      result.add_certainty(:uncertain)
      result.pop
    end
    
    def process_approximate
      result.add_certainty(:approximate)
      result.shift
    end
    
    def process_square_brackets(remain)
      return if remain.include?(:square_bracket_open) || remain.include?(:square_bracket_close)

      if options.square_bracket_interpretation == :edtf_set
        result.add_certainty(:one_of_set)
      else
        result.add_certainty(:supplied)
      end
        result.shift
        result.pop
    end

    def process_curly_brackets(remain)
      return if remain.include?(:curly_bracket_open) || remain.include?(:curly_bracket_close)

      result.add_certainty(:all_of_set)
      result.shift
      result.pop
    end
    
    def done?
      supplied_indicator? || curly? || approximate_indicator? || uncertain_indicator? ? false : true
    end

    def supplied_indicator?
      case result.types
        in [:square_bracket_open, *remain, :square_bracket_close]
        remain.include?(:square_bracket_open) || remain.include?(:square_bracket_close) ? false : true
      else
        false
      end
    end

    def curly?
      case result.types
        in [:curly_bracket_open, *remain, :curly_bracket_close]
        remain.include?(:curly_bracket_open) || remain.include?(:curly_bracket_close) ? false : true
      else
        false
      end
    end

    def approximate_indicator?
      case result.types
        in [:approximate, *]
        true
        in [:letter_c, *]
        true
      else
        false
      end
    end

    def uncertain_indicator?
      case result.types
      in [*, :question]
        true
      else
        false
      end
    end
  end
end
