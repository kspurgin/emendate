# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    class KnownUnknown
      include Datetypeable

      # @return [Emendate::SegmentSet]
      attr_reader :sources
      # @return [:no_date, :unknown_date]
      attr_reader :category

      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      # @param category [:no_date, :unknown_date]
      def initialize(sources:, category:)
        common_setup(binding)
        @category = category
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
