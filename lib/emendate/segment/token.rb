# frozen_string_literal: true

require 'emendate/segment/segment'

module Emendate
  class Token < Emendate::Segment
    extend Forwardable

    attr_reader :location

    COLLAPSIBLE_TOKEN_TYPES = %i[space single_dot standalone_zero]

    def collapsible?
      COLLAPSIBLE_TOKEN_TYPES.include?(type)
    end

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
