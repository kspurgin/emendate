# frozen_string_literal: true

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
  end
end