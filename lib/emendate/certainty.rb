# frozen_string_literal: true

module Emendate
  class Certainty

    attr_reader :tokens, :eof, :types, :values

    def initialize(tokens:)
      @tokens = tokens
      handle_eof
      @types = set_types
      @values = []
    end

    def check
      until done? do
        process_certainty
      end
      finalize
    end

    private

    def finalize
      unless eof.nil?
        tokens << eof
        set_types
      end
      self
    end

    def set_types
      @types = tokens.map(&:type)
    end
    
    def handle_eof
      if tokens[-1].type == :eof
        @eof = tokens[-1].clone
        tokens.pop
      else
        @eof = nil
      end
    end

    def process_certainty
      case set_types
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
      tokens.pop
    end
    
    def process_approximate
      values << :approximate
      tokens.shift
    end
    
    def process_supplied(remain)
      unless remain.include?(:square_bracket_open) || remain.include?(:square_bracket_close)
        values << :supplied
        tokens.shift
        tokens.pop
      end
    end
    
    def done?
      supplied_indicator? || approximate_indicator? || questionable_indicator? ? false : true
    end

    def supplied_indicator?
      case set_types
        in [:square_bracket_open, *remain, :square_bracket_close]
        remain.include?(:square_bracket_open) || remain.include?(:square_bracket_close) ? false : true
      else
        false
      end
    end

    def approximate_indicator?
      case set_types
        in [:approximate, *]
        true
        in [:c, *]
        true
      else
        false
      end
    end

    def questionable_indicator?
      case set_types
      in [*, :question]
        true
      else
        false
      end
    end
  end
end
