# frozen_string_literal: true

module Emendate
  module DateTypes
    class OpenRangeDate < Emendate::DateTypes::DateType
      attr_reader :use_date, :usage

      def initialize(**opts)
        super
        @use_date = opts[:use_date]
        @usage = opts[:usage]
      end

      def earliest
        use_date
      end

      def latest
        use_date
      end

      def lexeme
        "open #{usage} date"
      end

      def literal
        use_date.strftime('%Y%m%d').to_i
      end

      def range?
        false
      end

      def year
        literal
      end
    end
  end
end
