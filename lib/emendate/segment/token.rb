# frozen_string_literal: true

require "emendate/segment/segment"

module Emendate
  class Token < Emendate::Segment
    attr_reader :location

    def col
      return nil unless location

      location.col
    end

    def length
      return nil unless location

      location.length
    end

    private

    def post_initialize(opts)
      @location = opts[:location]
    end
  end
end
