# frozen_string_literal: true

module Emendate

  class RangeIndicator

    RANGE_INDICATOR_TYPES = %i[hyphen slash]
    
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
      
    end

    def range_indicator_present?
      working.types.any?{ |t| RANGE_INDICATOR_TYPES.include?(t) }
    end
    
    def current
      working[0]
    end

    def nxt(n = 1)
      working[n]
    end
  end
end
