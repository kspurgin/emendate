# frozen_string_literal: true

require_relative "datetypeable"

module Emendate
  module DateTypes
    # Represents a date string that cannot be processed. The type value
    # assigned indicates the problem:
    #
    # * invalid: string follows parseable date pattern, but results in an
    #   invalid date value
    # * untokenizable: string cannot be successfully tokenized
    # * unprocessable: string was successfully tokenized and identified as a
    #   pattern that the application cannot currently process
    #
    # The purpose of creating an error date type is to fail fast, gracefully,
    # and informatively, with a result that can be processed consistently
    # with other date types
    class Error
      include Datetypeable

      # @return [SegmentSet]
      attr_reader :sources
      # @return [#backtrace, nil]
      attr_reader :exception
      # @return [String, nil]
      attr_reader :message
      # @return [Symbol]
      attr_reader :error_type

      # @param sources [SegmentSet, Array<Segment>] Segments
      #   included in the date type
      # @param error_type [:untokenizable, :unprocessable]
      # @param exception [#backtrace] associated Exception object
      # @param message [String]
      def initialize(sources:, error_type:, exception: nil, message: nil)
        common_setup(binding)
        @error_type = error_type
        @exception = exception
        @message = if message
          message
        elsif exception
          exception.message
        end
      end

      # @return [NilClass]
      def earliest = nil

      # @return [NilClass]
      def latest = nil

      # @return [NilClass]
      def literal = nil

      # @return [NilClass]
      def earliest_at_granularity = nil

      # @return [NilClass]
      def latest_at_granularity = nil

      # @return [FalseClass]
      def range? = false

      # @return [:invalid_date_type, :unprocessable_date_type,
      #   :untokenizable_date_type]
      def type = :"#{error_type}_date_type"

      private

      def addable_token_types = []
    end
  end
end
