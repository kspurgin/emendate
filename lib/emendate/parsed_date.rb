# frozen_string_literal: true

require "forwardable"
require "json"

require_relative "segment_sets/certainty_helpers"

module Emendate
  # Wrapper around a DateType segment, used as part of Result
  class ParsedDate
    include Emendate::SegmentSets::CertaintyHelpers
    extend Forwardable

    attr_reader :original_string, :index_dates,
      :date_start, :date_end,
      :date_start_full, :date_end_full,
      :inclusive_range, :certainty,
      :date_type, :source

    def_delegators :@source, :sources, :type,
      :lexeme, :orig_string,
      :earliest, :earliest_at_granularity,
      :latest, :latest_at_granularity,
      :range_switch, :era

    # @param date [Emendate::DateTypes::DateType]
    # @param orig [String]
    # @param certainty [Array<Symbol>]
    def initialize(date:, orig:, certainty: [])
      raise(NonDateTypeError) unless date.date_type?

      @original_string = get_original_string(date, orig)
      @index_dates = []
      @date_start = nil
      @date_end = nil
      @date_start_full = date.earliest&.iso8601
      @date_end_full = date.latest&.iso8601
      @inclusive_range = date.range? ? true : nil
      @certainty = (certainty + date.certainty).flatten.uniq
      @date_type = date.class.name.split("::")[-1]
      @source = date
    end

    def to_h
      hashable_variables.map do |var|
        varsym = var.to_s.sub("@", "").to_sym
        [varsym, instance_variable_get(var)]
      end.to_h
        .merge({
          range_switch: range_switch,
          era: era
        })
    end

    def to_json(*_args)
      to_h.to_json
    end

    def valid_range?
      return true unless @inclusive_range
      return true if @date_start_full.nil? && !@date_end_full.nil?

      sd = Date.parse(@date_start_full)
      ed = Date.parse(@date_end_full)
      sd < ed
    end

    private

    def hashable_variables
      instance_variables - %i[@date_type @source]
    end

    def get_original_string(datetype, orig)
      if datetype.respond_to?(:orig)
        datetype.orig
      else
        orig
      end
    end
  end
end
