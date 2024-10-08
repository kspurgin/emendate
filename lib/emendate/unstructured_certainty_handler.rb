# frozen_string_literal: true

module Emendate
  class UnstructuredCertaintyHandler
    include Dry::Monads[:result]

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

      if question_as_uncertainty_digit?
        collapse_questions_to_uncertainty_digits
      end

      while indicators?
        seg = result.select { |seg| indicator?(seg) }.segments.first
        handle_indicator(seg)
      end

      Success(result)
    end

    private

    attr_reader :result, :working

    def indicator?(seg) = %i[approximate uncertain question].include?(seg.type)

    def indicators? = result.any? { |seg| indicator?(seg) }

    def question_as_uncertainty_digit?
      !result.consecutive_of_type(:question).empty?
    end

    def collapse_questions_to_uncertainty_digits
      questions = result.consecutive_of_type(:question)
      uncertainty = Emendate::UncertaintyDigits.new(
        sources: questions, lexeme: Array.new(questions.length, "?").join
      )
      result.replace_segments_with_new(segs: questions.segments,
        new: uncertainty)
    end

    def handle_indicator(seg)
      segidx = result.index_of(seg)
      dir = determine_direction(seg, segidx)
      collapse(dir, seg, segidx)
    end

    def determine_direction(seg, segidx)
      return :forward if segidx == 0
      return :backward if segidx == result.length - 1

      prefdir = preferred_direction(seg)
      altdir = alt_direction(prefdir)
      if adjacent_collapsible?(segidx, prefdir)
        prefdir
      elsif adjacent_not_collapsible?(segidx, altdir)
        # We only get here if neither direction collapses into a preferred
        #   type, so we keep the preferred direction
        prefdir
      else # Alt direction collapses into a preferred type
        altdir
      end
    end

    def preferred_direction(seg)
      case seg.type
      when :approximate then :forward
      when :question then :backward
      when :uncertain then :forward
      end
    end

    def alt_direction(dir)
      (dir == :forward) ? :backward : :forward
    end

    def adjacent_collapsible?(segidx, dir)
      idx = (dir == :forward) ? segidx + 1 : segidx - 1
      target = result[idx]
      target.date_part? || target.date_type? || target.number?
    end

    def adjacent_not_collapsible?(segidx, dir)
      !adjacent_collapsible?(segidx, dir)
    end

    def collapse(dir, seg, idx)
      target = (dir == :forward) ? result[idx + 1] : result[idx - 1]

      set_qualifier(target, seg, precision(dir, idx))

      case dir
      when :forward
        result.collapse_segment(seg, :forward)
      when :backward
        result.collapse_segment(seg, :backward)
      end
    end

    def precision(dir, idx)
      return :beginning if idx == 0
      return :end if idx == (result.length - 1)

      case dir
      when :forward then :rightward
      when :backward then :leftward
      end
    end

    def set_qualifier(target, seg, precision)
      target.add_qualifier(
        Emendate::Qualifier.new(
          type: qual_type(seg),
          precision: precision,
          lexeme: qual_lexeme(seg)
        )
      )
    end

    def qual_type(seg)
      case seg.type
      when :question
        :uncertain
      else
        seg.type
      end
    end

    def qual_lexeme(seg)
      if seg.type == :question
        ""
      elsif seg.type == :approximate && seg.lexeme.match?(/^ca?\.?\s?$/i)
        "circa"
      else
        seg.lexeme.strip
      end
    end
  end
end
