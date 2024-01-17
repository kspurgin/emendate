# frozen_string_literal: true

require "emendate/result_editable"

module Emendate
  class InferredDateHandler
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
      return Success(result) unless indicators?

      if whole_string_inferred?
        process_whole_string
      else
        process_pair(pairs.first) until pairs.empty?
      end

      if indicators?
        case Emendate.options.mismatched_bracket_handling
        when :failure
          return Failure(:mismatched_brackets)
        else
          process_mismatched
        end
      end

      Success(result)
    end

    private

    attr_reader :result, :working

    def indicators?
      result.types.any? { |type| indicators.include?(type) }
    end

    def indicators = %i[square_bracket_open square_bracket_close]

    def whole_string_inferred?
      result[0].type == :square_bracket_open &&
        result[-1].type == :square_bracket_close &&
        no_inner_brackets?
    end

    def no_inner_brackets? = !inner_brackets?

    def inner_brackets?
      result[1..-2].any? { |seg| indicator?(seg) }
    end

    def indicator?(seg) = indicators.include?(seg.type)

    def pairs
      result.when_type(:square_bracket_open)
        .map { |open| get_pair_for(open) }
        .compact
    end

    def get_pair_for(open)
      open_ind = result.find_index(open)
      close_ind = result.when_type(:square_bracket_close)
        .map { |seg| result.find_index(seg) }
        .reject { |ind| ind < open_ind }
        .first
      return nil unless close_ind

      Range.new(open_ind, close_ind)
    end

    def process_whole_string
      result.add_qualifier(Emendate::Qualifier.new(
        type: :inferred,
        precision: :whole,
        sources: [result[0], result[-1]]
      ))
      collapse_enclosing_tokens
    end

    def process_pair(range)
      wrapped = range.to_a
      open = wrapped.shift
      close = wrapped.pop
      wrapped.each do |ind|
        add_qualifier(
          result[ind], :single_segment, [result[open], result[close]]
        )
      end
      collapse_token_pair_backward(result[wrapped.last], result[close])
      collapse_token_pair_forward(result[open], result[wrapped.first])
    end

    def add_qualifier(segment, precision, sources)
      segment.add_qualifier(Emendate::Qualifier.new(
        type: :inferred,
        precision: precision,
        sources: sources
      ))
    end

    def process_mismatched
      result.select { |seg| indicator?(seg) }
        .reverse_each { |seg| absorb(seg) }
    end

    def absorb(segment)
      case segment.type
      when :square_bracket_open then absorb_open(segment)
      else absorb_close(segment)
      end
    end

    def absorb_open(segment)
      if at_end?(segment)
        absorb_backward(segment)
      else
        absorb_forward(segment)
      end
    end

    def absorb_close(segment)
      if at_beginning?(segment)
        absorb_forward(segment)
      else
        absorb_backward(segment)
      end
    end

    def at_beginning?(segment)
      ind = result.find_index(segment)
      ind == 0
    end

    def at_end?(segment)
      ind = result.find_index(segment)
      ind == result.length - 1
    end

    def absorb_forward(segment)
      ind = result.find_index(segment)
      nextind = ind + 1
      collapse_token_pair_forward(result[ind], result[nextind])
    end

    def absorb_backward(segment)
      ind = result.find_index(segment)
      prevind = ind - 1
      collapse_token_pair_backward(result[prevind], result[ind])
    end
  end
end
