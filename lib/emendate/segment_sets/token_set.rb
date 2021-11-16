# frozen_string_literal: true

require_relative 'segment_set'

module Emendate
  module SegmentSets
    class TokenSet < Emendate::SegmentSets::SegmentSet
      def any_unknown?
        types.any?(:unknown)
      end

      def unknown
        self.select{ |t| t.type == :unknown }
      end
    end
  end
end
