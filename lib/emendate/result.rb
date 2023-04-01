# frozen_string_literal: true

require 'json'

module Emendate
  class Result

    attr_reader :original_string, :errors, :warnings, :dates

    # @param pm [Emendate::ProcessingManager]
    def initialize(pm)
      @pm = pm
      @original_string = pm.orig_string
      @errors = map_errors
      @warnings = pm.warnings
      if pm.state == :failed
        @dates = []
      else
        @dates = pm.tokens.select{ |t| t.date_type? }
          .map do |t|
            Emendate::ParsedDate.new(
            date: t,
            certainty: pm.tokens.certainty,
            orig: original_string
          )
          end
      end
    end

    def compile_date_info(method:, delim:)
      dates.map(&method).join(delim)
    end

    def date_count
      dates.length
    end

    def to_h
      {
        original_string: original_string,
        dates: dates.map(&:to_h),
        errors: errors,
        warnings: warnings
      }
    end

    def to_json
      to_h.to_json
    end

    private

    attr_reader :pm

    def map_errors
      pm.errors.map do |err|
        if err.is_a?(String)
          err
        else
          Emendate::ErrorUtil.msg(err).join("\n")
        end
      end
    end
  end
end
