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
  end
end
