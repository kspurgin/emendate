# frozen_string_literal: true

module Emendate
  class BracketPairHandler
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = tokens.class.new.copy(tokens)
    end

    def call
      %i[square angle].each { |type| yield handle_bracket_type(type) }

      Success(result)
    end

    private

    attr_reader :result, :bracket_type

    def handle_bracket_type(type)
      return Success(result) if type == :square &&
        !Emendate.options.square_bracket_interpretation == :inferred_date
      return Success(result) if type == :angle &&
        !Emendate.options.square_bracket_interpretation == :temporary

      @open_bracket = nil
      @close_bracket = nil
      @bracket_type = type
      return Success(result) unless indicators?

      if whole_string_wrapped?
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

    def open_bracket = @open_bracket ||= :"#{bracket_type}_bracket_open"

    def close_bracket = @close_bracket ||= :"#{bracket_type}_bracket_close"

    def indicators?
      result.types.any? { |type| indicators.include?(type) }
    end

    def indicators = [open_bracket, close_bracket]

    def whole_string_wrapped?
      result[0].type == open_bracket &&
        result[-1].type == close_bracket &&
        no_inner_brackets?
    end

    def no_inner_brackets? = !inner_brackets?

    def inner_brackets?
      result[1..-2].any? { |seg| indicator?(seg) }
    end

    def indicator?(seg) = indicators.include?(seg.type)

    def pairs
      result.when_type(open_bracket)
        .map { |open| get_pair_for(open) }
        .compact
    end

    def get_pair_for(open)
      open_ind = result.find_index(open)
      close_ind = result.when_type(close_bracket)
        .map { |seg| result.find_index(seg) }
        .reject { |ind| ind < open_ind }
        .first
      return nil unless close_ind

      Range.new(open_ind, close_ind)
    end

    def qual_type
      case bracket_type
      when :square then :inferred
      when :angle then :temporary
      end
    end

    def process_whole_string
      result.add_qualifier(
        Emendate::Qualifier.new(type: qual_type, precision: :whole)
      )
      result.collapse_enclosing_tokens
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
      result.collapse_token_pair_backward(result[wrapped.last], result[close])
      result.collapse_token_pair_forward(result[open], result[wrapped.first])
    end

    def add_qualifier(segment, precision, sources)
      segment.add_qualifier(
        Emendate::Qualifier.new(type: qual_type, precision: precision)
      )
    end

    def process_mismatched
      result.select { |seg| indicator?(seg) }
        .reverse_each { |seg| absorb(seg) }
    end

    def absorb(segment)
      case segment.type
      when open_bracket then absorb_open(segment)
      else absorb_close(segment)
      end
    end

    def absorb_open(segment)
      if result.is_last_seg?(segment)
        result.collapse_segment(segment, :backward)
      else
        result.collapse_segment(segment, :forward)
      end
    end

    def absorb_close(segment)
      if result.is_first_seg?(segment)
        result.collapse_segment(segment, :forward)
      else
        result.collapse_segment(segment, :backward)
      end
    end
  end
end
