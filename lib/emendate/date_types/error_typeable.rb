# frozen_string_literal: true

module Emendate
  module DateTypes
    # Mixin module for DateTypes that wrap an processing errors
    module ErrorTypeable
      def earliest
        nil
      end

      def latest
        nil
      end

      def lexeme
        sources.orig_string
      end

      def literal
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
