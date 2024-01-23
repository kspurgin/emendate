# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    class KnownUnknown
      include Datetypeable

      # @return [SegmentSet
      attr_reader :sources

      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      def initialize(sources:)
        common_setup(binding)
      end

      # @return [nil]
      def earliest
        nil
      end

      # @return [nil]
      def latest
        nil
      end

      # @return [nil]
      def earliest_at_granularity
        nil
      end

      # @return [nil]
      def latest_at_granularity
        nil
      end

      # @return [String]
      def lexeme
        case Emendate.options.unknown_date_output
        when :orig
          sources.lexeme
        else
          Emendate.options.unknown_date_output_string
        end
      end

      # @return [nil]
      def literal
        nil
      end

      # @return [FalseClass]
      def range?
        false
      end

      private

      def addable_token_types = []
    end
  end
end
