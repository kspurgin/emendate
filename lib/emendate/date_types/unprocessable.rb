# frozen_string_literal: true

module Emendate
  module DateTypes
    class Unprocessable < Emendate::DateTypes::DateType
      attr_reader :lexeme, :literal

      def initialize(**opts)
        super
        @literal = opts[:literal].is_a?(Integer) ? opts[:literal] : opts[:literal].to_i
        @lexeme = opts[:children].map(&:lexeme)
          .join
      end

      def earliest
        nil
      end

      def latest
        nil
      end

      def earliest_at_granularity
        nil
      end

      def latest_at_granularity
        nil
      end

      def range?
        false
      end
    end
  end
end
