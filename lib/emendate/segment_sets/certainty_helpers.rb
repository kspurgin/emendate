# frozen_string_literal: true

module Emendate
  module SegmentSets
    # mixin module to add commonly useful boolean methods for certainty values
    module CertaintyHelpers
      def certain?
        certainty.empty?
      end

      def approximate?
        certainty.any?(:approximate)
      end

      def approximate_and_uncertain?
        approximate? && uncertain?
      end

      def inferred?
        certainty.any?(:inferred)
      end

      def uncertain?
        certainty.any?(:uncertain)
      end

      def all_of_set?
        certainty.any?(:all_of_set)
      end

      def one_of_set?
        certainty.any?(:one_of_set)
      end
    end
  end
end
