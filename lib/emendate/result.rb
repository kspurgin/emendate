# frozen_string_literal: true

require 'json'

module Emendate
  class Result

    attr_reader :original_string, :errors, :warnings, :dates

    def initialize(resulthash)
      @original_string = resulthash[:original_string]
      @errors = resulthash[:errors]
      @warnings = resulthash[:warnings]
      @dates = resulthash[:result]
      verify_ranges
    end

    def compile_date_info(method:, delim:)
      dates.map(&method).join(delim)
    end
    
    def date_count
      dates.length
    end
    
    def to_h
      {
        original_string: @original_string,
        dates: @dates.map(&:to_h),
        errors: @errors,
        warnings: @warnings
      }
    end

    def to_json
      to_h.to_json
    end
    
    private

    def verify_ranges
      @dates.map(&:valid_range?).each_with_index do |vr, i|
        next if vr == true

        @warnings << "Date ##{i + 1} is not a valid date range"
      end
    end
  end
end
