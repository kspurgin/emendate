# frozen_string_literal: true

require 'emendate/segment/token'
require 'emendate/segment/derived_segment'

module Emendate
  class DerivedToken < Emendate::Token
    include DerivedSegment

    private

    def post_initialize(opts)
      derive(opts)

      if sources.length == 1
        @location = sources[0].location if location.nil?
      end
    end
  end
end
