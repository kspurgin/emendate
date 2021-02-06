# frozen_string_literal: true

module Emendate
  module DateTypes
    class Year < Emendate::DateTypes::DateType
      attr_reader :year
      def initialize(**opts)
        super
        @year = opts[:year].is_a?(Integer) ? opts[:year] : opts[:year].to_i
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
