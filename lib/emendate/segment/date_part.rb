# frozen_string_literal: true

require 'emendate/segment/segment'
require 'emendate/segment/derived_segment'

module Emendate
  class DatePart < Emendate::Segment
    include DerivedSegment

    # allows any subclass of SegmentSet to return a list of segments representing date parts
    def date_part?
      true
    end

    private

    def post_initialize(opts)
      # todo - refactor so you can take this duplicative reassignment out
      opts[:sources] = opts[:source_tokens]
      derive(opts)
    end
  end
end
