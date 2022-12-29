# frozen_string_literal: true

module Emendate
  class OldCertaintyChecker

    attr_reader :result, :working

    def initialize(tokens:)
      @result = tokens.class.new.copy(tokens)
    end

    def check
      until whole_done? do
        process_whole_certainty
      end

      @working = result.class.new.copy(result)
      result.clear

      until working.empty? do
        process_part_certainty
      end

      result
    end

    private

    def process_part_certainty
      return if working.empty?

      processor = processing_function
      return if processor.nil?

      send(processor)
    end

    def processing_function
      return nil if working.empty?

      if working[0].is_a?(Emendate::NumberToken)
        :check_after_number
      elsif uncertainty_indicator?
        :set_number_certainty
      elsif set_indicator?
        :set_set_certainty
      else
        :passthrough
      end
    end

    # def set_indicator?(n = 0)
    #   %i[and or].include?(working[n].type)
    # end

    def set_indicator?(n = 0)
      %i[and or].include?(working[n].type)
    end

    def uncertainty_indicator?(n = 0)
      %i[question percent tilde].include?(working[n].type)
    end

    def passthrough
      current = working.shift
      result << current
    end

    def certainty_val(token)
      case token.type
      when :and
        %i[all_of_set]
      when :or
        %i[one_of_set]
      when :question
        %i[uncertain]
      when :tilde
        %i[approximate]
      when :percent
        %i[approximate uncertain]
      end
    end

    def check_after_number
      number = working[0]
      if nxt.nil?
        passthrough
      elsif uncertainty_indicator?(1)
        certainty = certainty_val(nxt).map{ |v| "leftward_#{v}".to_sym }
        number.add_certainty(certainty)
        passthrough
        working.shift
      else
        passthrough
      end
    end

    def set_number_certainty
      certainty = certainty_val(working[0])
      if nxt.nil?
        result.warnings << "#{working[0].lexeme} appears at end of string and was not handled by whole-value processor"
        passthrough
      elsif nxt.is_a?(Emendate::NumberToken)
        nxt.add_certainty(certainty)
        working.shift
        passthrough
      else
        result.warnings << "#{working[0].lexeme} followed by non-number"
        passthrough
      end
      process_part_certainty
    end

    def set_set_certainty
      certainty = certainty_val(working[0])
      if nxt.nil?
        result.warnings << "#{working[0].lexeme} appears at end of string and was not handled by whole-value processor"
        passthrough
      else
        result.add_certainty(certainty)
        working.shift
        passthrough
      end
      process_part_certainty
    end

    def nxt(n = 1)
      working[n]
    end

    def process_whole_certainty
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
      in [*, :tilde]
        process_edtf_approximate
      in [*, :percent]
        process_edtf_approximate_and_uncertain
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

    def process_edtf_approximate
      result.add_certainty(:approximate)
      result.pop
    end

    def process_edtf_approximate_and_uncertain
      result.add_certainty(:approximate)
      result.add_certainty(:uncertain)
      result.pop
    end

    def process_square_brackets(remain)
      return if remain.include?(:square_bracket_open) || remain.include?(:square_bracket_close)

      if Emendate.options.square_bracket_interpretation == :edtf_set
        result.add_certainty(:one_of_set)
      else
        result.add_certainty(:inferred)
        result.is_inferred
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

    def whole_done?
      !(inferred_indicator? || curly? || approximate_indicator? || uncertain_indicator?)
    end

    def inferred_indicator?
      case result.types
      in [:square_bracket_open, *remain, :square_bracket_close]
        !(remain.include?(:square_bracket_open) || remain.include?(:square_bracket_close))
      else
        false
      end
    end

    def curly?
      case result.types
      in [:curly_bracket_open, *remain, :curly_bracket_close]
        !(remain.include?(:curly_bracket_open) || remain.include?(:curly_bracket_close))
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
      in [*, :tilde]
        true
      in [*, :percent]
        true
      else
        false
      end
    end

    def uncertain_indicator?
      case result.types
      in [*, :question]
        true
      in [*, :percent]
        true
      else
        false
      end
    end
  end
end
