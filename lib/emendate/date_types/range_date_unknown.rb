# frozen_string_literal: true

module Emendate
  module DateTypes
    class RangeDateUnknown < Emendate::DateTypes::DateType
      include OpenOrUnknowable

      attr_reader :use_date, :usage

      def lexeme
        "unknown #{usage} date"
      end
    end
  end
end
