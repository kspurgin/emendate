# frozen_string_literal: true

module Emendate
  module DateTypes
    class Unprocessable < Emendate::DateTypes::DateType
      attr_reader :literal

      def initialize(**opts)
        super
        @literal = opts[:literal].is_a?(Integer) ? opts[:literal] : opts[:literal].to_i
      end

      def earliest
        nil
      end

      def latest
        nil
      end

      def lexeme
        literal
      end

      def range?
        false
      end
    end
  end
end
