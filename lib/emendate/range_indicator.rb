# frozen_string_literal: true

module Emendate

  class RangeIndicator
    attr_reader :result, :warnings

    def initialize(tokens:)
      @working = Emendate::SegmentSets::MixedSet.new.copy(tokens)
      @result = Emendate::SegmentSets::MixedSet.new.copy(tokens)
      result.clear
      @warnings = []
    end

    def indicate
      has_range_indicator? ? handle_range : passthrough_all
      result
    end

    private

    attr_reader :working

    def before_range_indicator?
      nxt.type == :range_indicator
    end

    def collapse_range
      unless current.date_type?
        passthrough
        return
      end

      if nxt.nil?
        passthrough
        return
      end
      
      unless before_range_indicator?
        passthrough
        return
      end

      result << Emendate::DateTypes::Range.new(startdate: current,
                                               range_indicator: nxt,
                                               enddate: nxt(2))

      [current, nxt, nxt(2)].each{ |s| working.delete(s) }
    end

    def current
      working[0]
    end

    def handle_range
      
      collapse_range until working.empty?

      
      validate
    end

    def has_range_indicator?
      working.types.include?(:range_indicator)
    end

    def nxt(n = 1)
      working[n]
    end

    def passthrough
      result << working.shift
    end

    def passthrough_all
      passthrough until working.empty?
    end

    def validate
      result.each do |part|
        next unless part.type == :range_date_type
        next if part.latest > part.earliest

        @warnings << "Not a valid range: #{part.lexeme}"
      end
    end
  end
end
