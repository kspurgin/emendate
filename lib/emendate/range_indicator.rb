# frozen_string_literal: true

module Emendate

  class RangeIndicator
    attr_reader :options, :result
    attr_accessor :working

    def initialize(tokens:, options: {})
      @options = options
      @working = Emendate::MixedSet.new.copy(tokens)
      @result = Emendate::MixedSet.new.copy(tokens)
      result.clear
    end

    def indicate
      unless range_indicator_present?
        working.each{ |s| result << s }
        working.clear
        return result
      end

      until working.empty?
        collapse_range
      end

      result
    end

    private

    def collapse_range
      unless current.date_type?
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

    def range_indicator_present?
      working.types.include?(:range_indicator)
    end

    def current
      working[0]
    end

    def nxt(n = 1)
      working[n]
    end

    def before_range_indicator?
      nxt.type == :range_indicator ? true : false
    end

    def passthrough
      result << working.shift
    end
  end
end
