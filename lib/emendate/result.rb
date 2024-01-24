# frozen_string_literal: true

require "json"

module Emendate
  # Wrapper class around one or more {Emendate::ParsedDate}s.
  #
  # Presents any errors and warnings from the date parsing process, along with
  # the {Emendate::ProcessingManager} and its detailed, step-by-step audit of
  # the process.
  #
  # The public API is loosely based on
  # {https://github.com/alexduryee/timetwister timetwister} and should remain
  # consistent with that tool.
  class Result
    # @return [String] the original string parsed to generate this {Result}
    attr_reader :original_string
    # @macro set_type_attr
    attr_reader :set_type
    # @return [Array] information about why string was unable to be parsed
    #   successfully
    attr_reader :errors
    # @return [Array] information about how ambiguous date options or other
    #   settings were applied.
    attr_reader :warnings
    # @return [Array<Emendate::ParsedDate>]
    attr_reader :dates
    # @return [Emendate::ProcessingManager]
    attr_reader :pm

    # @param pm [Emendate::ProcessingManager]
    def initialize(pm)
      @pm = pm
      @original_string = pm.orig_string
      @errors = map_errors
      @warnings = pm.warnings
      @set_type = pm.tokens.set_type
      @dates = create_parsed_dates
    end

    # @param method [Symbol] name of {Emendate::ParsedDate} public method
    # @param delim [String] for joining multiple values
    # @return [String] concatenated result of calling method on all the dates
    def compile_date_info(method:, delim:)
      dates.map(&method).join(delim)
    end

    # @return [Integer]
    def date_count
      dates.length
    end

    # @return [Hash] representation of {Result}
    def to_h
      {
        original_string: original_string,
        dates: dates.map(&:to_h),
        errors: errors,
        warnings: warnings
      }
    end

    # @return [String]
    def to_json
      to_h.to_json
    end

    private

    def create_parsed_dates
      pm.tokens.select { |t| t.date_type? }
        .map do |t|
          Emendate::ParsedDate.new(
            date: t,
            qualifiers: pm.tokens.qualifiers,
            orig: original_string
          )
        end
    end

    def map_errors
      pm.errors
        .reject { |err| err.is_a?(Emendate::SegmentSet) }
        .map do |err|
        if err.is_a?(String)
          err
        else
          Emendate::ErrorUtil.msg(err).join("\n")
        end
      end
    end
  end
end
