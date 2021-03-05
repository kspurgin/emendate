# frozen_string_literal: true

require 'json'

module Emendate
  class ParsedDate

    attr_reader :original_string, :index_dates,
                :date_start, :date_end,
                :date_start_full, :date_end_full,
                :inclusive_range, :certainty

    def initialize(datetype, whole_certainty = [])
      @original_string = nil
      @index_dates = []
      @date_start = nil
      @date_end = nil
      @date_start_full = datetype.earliest.nil? ? nil : datetype.earliest.iso8601
      @date_end_full = datetype.latest.nil? ? nil : datetype.latest.iso8601
      @inclusive_range = datetype.range? ? true : nil
      @certainty = whole_certainty
      datetype.certainty.each{ |c| certainty << c }
      certainty.flatten!
      certainty.uniq!
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
  end
end
