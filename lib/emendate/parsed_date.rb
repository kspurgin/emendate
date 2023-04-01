# frozen_string_literal: true

require 'json'

module Emendate
  # Wrapper around a DateType segment, used as part of Result
  class ParsedDate
    attr_reader :original_string, :index_dates,
      :date_start, :date_end,
      :date_start_full, :date_end_full,
      :inclusive_range, :certainty

    # @param date [Emendate::DateTypes::DateType]
    # @param orig [String]
    # @param certainty [Array<Symbol>]
    def initialize(date:, orig:, certainty: [])
      fail(NonDateTypeError) unless date.is_a?(Emendate::DateTypes::DateType)

      @original_string = get_original_string(date, orig)
      @index_dates = []
      @date_start = nil
      @date_end = nil
      @date_start_full = date.earliest.nil? ? nil : date.earliest.iso8601
      @date_end_full = date.latest.nil? ? nil : date.latest.iso8601
      @inclusive_range = date.range? ? true : nil
      @certainty = (certainty + date.certainty).flatten.uniq
      self
    end

    def to_h
      h = {}
      self.instance_variables.each do |iv|
        iv = iv.to_s.sub('@', '')
        h[iv.to_sym] = self.send(iv)
      end
      h
    end

    def to_json
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

    def get_original_string(datetype, orig)
      if datetype.respond_to?(:orig)
        datetype.orig
      else
        orig
      end
    end

  end
end
