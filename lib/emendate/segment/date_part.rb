# frozen_string_literal: true

require 'emendate/segment/segment'
require 'emendate/segment/derived_segment'

module Emendate
  # A segment that represents part of a date
  # Usage:
  # Emendate::DatePart.new(type: Symbol,
  #                        lexeme: String,
  #                        literal: Integer,
  #                        sources: [array of tokens/segments])
  class DatePart < Emendate::Segment
    include DerivedSegment

    # allows any subclass of SegmentSet to return a list of segments representing date parts
    def date_part?
      true
    end

    private

    def post_initialize(opts)
      derive(opts)
    end
  end
end
