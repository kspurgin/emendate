# frozen_string_literal: true

module Emendate
  module DateTypes
    class RangeDateOpen < Emendate::DateTypes::DateType
      include OpenOrUnknowable

      attr_reader :use_date, :usage

      def lexeme
        "open #{usage} date"
      end
    end
  end
end
