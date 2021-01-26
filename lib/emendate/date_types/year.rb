# frozen_string_literal: true

module Emendate
  module DateTypes
    class Year < Emendate::DateTypes::DateType
      def initialize(**opts)
        super
      end

      def earliest
        Date.new(year, 1, 1)
      end

      def latest
        Date.new(year, 12, -1)
      end

      def lexeme
        year.to_s
      end
    end
  end
end
