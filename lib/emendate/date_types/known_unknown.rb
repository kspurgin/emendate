# frozen_string_literal: true

module Emendate
  module DateTypes
    class KnownUnknown < Emendate::DateTypes::DateType
      attr_reader :lexeme

      # expect :lexeme, :children
      def initialize(**opts)
        super
        @lexeme = opts[:lexeme]
        @children = opts[:children]
      end

      def earliest
        nil
      end

      def latest
        nil
      end

      def literal
        lexeme
      end

      def range?
        false
      end
    end
  end
end
