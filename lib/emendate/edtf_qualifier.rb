# frozen_string_literal: true

module Emendate
  # As per https://www.loc.gov/standards/datetime/, handles the following when
  #   the `:edtf` option is true:
  #
  # Character interpretation:
  #
  # * ? - uncertain
  # * ~ - approximate
  # * % - approximate and uncertain
  #
  # Rules:
  #
  # * A qualifier at the end of a date expression applies to the whole
  #   date. "2004-06-11?" means the date is uncertainly 2004-06-11
  # * A qualifier to the immediate right of a date component applies to that
  #   component and to all leftward components. "2004-06?-11" means we're
  #   uncertain that it was in 2004 or June, but we know it was on the 11th.
  # * A qualifier to the immediate left of a date component applies only to
  #   that component. "2004-?06-11" means we know it was in 2004, are uncertain
  #   it was in June, but know it was the 11th.
  class EdtfQualifier
    include Dry::Monads[:result]

    EDTF_CHARS = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
      "?", "~", "%", " ", "-", "X", "/", "."]

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
      return Success(result) unless edtf?

      @working = result.class.new.copy(result)
      result.clear

      process_working until working.empty?

      Success(result)
    end

    private

    attr_reader :result, :working

    def indicators = %i[question tilde percent]

    def indicators?
      result.types.any? { |type| indicators.include?(type) }
    end

    def indicator?(seg) = indicators.include?(seg.type)

    def edtf?
      chk = result.orig_string.chars.uniq - EDTF_CHARS
      chk.empty?
    end

    def process_working
      return nil if working.empty?

      seg = working[0]
      function = if working.length < 2
        proc { passthrough }
      elsif indicator?(seg) && working[1].number?
        proc { qualify_next_segment }
      elsif seg.number? && indicator?(working[1])
        proc { leftward_qualify }
      else
        proc { passthrough }
      end

      function.call
    end

    def qualify_next_segment
      qual_seg = working.shift
      num_seg = working.shift
      num_seg.add_qualifier(
        Emendate::Qualifier.new(
          type: qualifier_type(qual_seg),
          precision: :single_segment
        )
      )
      result << qual_seg
      result << num_seg
      result.collapse_segment(qual_seg, :forward)
    end

    def leftward_qualify
      num_seg = working.shift
      qual_seg = working.shift
      num_seg.add_qualifier(Emendate::Qualifier.new(
        type: qualifier_type(qual_seg),
        precision: :leftward
      ))
      result << num_seg
      result << qual_seg
      result.collapse_segment(qual_seg, :backward)
    end

    def qualifier_type(seg)
      case seg.type
      when :question then :uncertain
      when :tilde then :approximate
      when :percent then :approximate_and_uncertain
      end
    end

    def passthrough
      current = working.shift
      result << current
    end
  end
end
