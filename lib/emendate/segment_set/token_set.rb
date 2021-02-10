# frozen_string_literal: true

require 'emendate/segment_set/segment_set'

module Emendate
  class TokenSet < Emendate::SegmentSet
    def any_unknown?
      types.any?(:unknown) ? true : false
    end

    def unknown
      self.select{ |t| t.type == :unknown }
    end
  end
end
