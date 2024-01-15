# frozen_string_literal: true

require "emendate/result_editable"

module Emendate
  class CertaintyChecker
    include Dry::Monads[:result]
    include ResultEditable

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = tokens.class.new.copy(tokens)
    end

    def call
      while indicators_left?
        pre = result.types.dup
        process_whole_certainty

        break if result.types == pre
      end

      @working = result.class.new.copy(result)
      result.clear

      process_part_certainty until working.empty?

      Success(result)
    end

    private

    attr_reader :result, :working

    def indicators_left?
      inferred_indicator? ||
        curly? ||
        approximate_indicator? ||
        uncertain_indicator?
    end

    def inferred_indicator?
      case result.types
      in [:square_bracket_open, *remain, :square_bracket_close]
        !(
          remain.include?(:square_bracket_open) ||
            remain.include?(:square_bracket_close)
        )
      else
        false
      end
    end

    def curly?
      case result.types
      in [:curly_bracket_open, *remain, :curly_bracket_close]
        !(
          remain.include?(:curly_bracket_open) ||
            remain.include?(:curly_bracket_close)
        )
      else
        false
      end
    end

    def approximate_indicator?
      case result.types
      in [:approximate, *]
        true
      in [*, :approximate]
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
      return true if result.types.include?(:uncertain)

      case result.types
      in [*, :question]
        true
      in [*, :percent]
        true
      else
        false
      end
    end

    def process_whole_certainty
      case result.types
      in [:square_bracket_open, *remain, :square_bracket_close]
        process_square_brackets(remain)
      in [:curly_bracket_open, *remain, :curly_bracket_close]
        process_curly_brackets(remain)
      in [:approximate, :uncertain, *]
        process_approximate_and_uncertain
      in [:uncertain, :approximate, *]
        process_approximate_and_uncertain
      in [:approximate, *]
        process_approximate
      in [*, :approximate]
        process_edtf_approximate
      in [:letter_c, *]
        process_approximate
      in [*, :question]
        process_uncertain
      in [*, :tilde]
        process_edtf_approximate
      in [*, :percent]
        process_edtf_approximate_and_uncertain
      in [:number4, :comma, :uncertain, :month]
        process_segment(2, :forward)
      else
        nil
      end
    end

    def process_part_certainty
      return if working.empty?

      processor = processing_function
      return if processor.nil?

      send(processor)
    end

    def processing_function
      return nil if working.empty?

      if working[0].is_a?(Emendate::Number)
        :check_after_number
      elsif uncertainty_indicator?
        :set_date_certainty
      elsif set_indicator?
        :set_set_certainty
      else
        :passthrough
      end
    end

    def uncertainty_indicator?(n = 0)
      %i[question percent tilde uncertain].include?(working[n].type)
    end

    def set_indicator?(n = 0)
      %i[and or].include?(working[n].type)
    end

    def collapse_set?
      Emendate.options.and_or_date_handling == :single_range
    end

    ##################
    # Whole processors
    ##################

    def process_square_brackets(remain)
      return if remain.include?(:square_bracket_open) ||
        remain.include?(:square_bracket_close)

      if Emendate.options.square_bracket_interpretation == :edtf_set
        result.add_certainty(:one_of_set) unless collapse_set?
      else
        result.add_certainty(:inferred)
        result.is_inferred
      end
      collapse_enclosing_tokens
    end

    def process_curly_brackets(remain)
      return if remain.include?(:curly_bracket_open) ||
        remain.include?(:curly_bracket_close)

      result.add_certainty(:all_of_set) unless collapse_set?
      collapse_enclosing_tokens
    end

    def process_approximate
      result.add_certainty(:approximate)
      collapse_first_token
    end

    def process_edtf_approximate
      result.add_certainty(:approximate)
      collapse_last_token
    end

    def process_uncertain
      result.add_certainty(:uncertain)
      collapse_last_token
    end

    def process_approximate_and_uncertain
      result.add_certainty(:approximate)
      result.add_certainty(:uncertain)
      2.times { collapse_first_token }
    end

    def process_edtf_approximate_and_uncertain
      result.add_certainty(:approximate)
      result.add_certainty(:uncertain)
      collapse_last_token
    end

    # @param indidx [Integer] index of uncertainty indicator to merge
    # @param direction [:forward, :backward] to merge the indicator
    def process_segment(idx, direction)
      indicator = result[idx]
      cert = certainty_val(indicator)
      targetidx = (direction == :forward) ? idx + 1 : idx - 1
      target = result[targetidx]
      cert.each do |certval|
        result.add_certainty(:"#{certval}_#{target.type}")
      end
      srcs = (direction == :forward) ? [indicator, target] : [target, indicator]
      collapse_token_pair(srcs[0], srcs[1], direction)
    end

    ####################
    # Partial processors
    ####################

    def check_after_number
      number = working[0]
      if nxt.nil?
        passthrough
      elsif uncertainty_indicator?(1)
        certainty = certainty_val(nxt).map { |v| :"leftward_#{v}" }
        number.add_certainty(certainty)
        result << number
        result << nxt
        collapse_last_token
        working.shift(2)
      else
        passthrough
      end
    end

    def set_date_certainty
      indicator = working.shift
      certainty = certainty_val(indicator)
      if working.first.nil?
        result.warnings << "#{indicator.lexeme} appears at end of string and "\
                           "was not handled by whole-value processor"
        result << indicator
      elsif working.first.is_a?(Emendate::Number)
        number = working.shift
        number.add_certainty(certainty)
        result << indicator
        result << number
        collapse_token_pair_forward(result[-2], result[-1])
      else
        result.warnings << "#{indicator.lexeme} followed by non-number"
        result << indicator
      end
      process_part_certainty
    end

    def set_set_certainty
      certainty = certainty_val(working[0])
      if nxt.nil?
        result.warnings << "#{working[0].lexeme} appears at end of string and "\
                           "was not handled by whole-value processor"
      else
        result.add_certainty(certainty)
        result << Emendate::Segment.new(
          type: :date_separator, sources: [working[0]]
        )
        working.shift
      end
      passthrough
      process_part_certainty
    end

    def passthrough
      current = working.shift
      result << current
    end

    def certainty_val(token)
      case token.type
      when :and
        collapse_set? ? [] : %i[all_of_set]
      when :or
        collapse_set? ? [] : %i[one_of_set]
      when :question
        %i[uncertain]
      when :tilde
        %i[approximate]
      when :percent
        %i[approximate uncertain]
      when :uncertain
        %i[uncertain]
      end
    end

    def nxt(n = 1)
      working[n]
    end
  end
end
