# frozen_string_literal: true

module Emendate
  module DateTypes
    class KnownUnknown < Emendate::DateTypes::DateType
      attr_reader :lexeme

      # Expect to be initialized with:
      #  sources: Emendate::SegmentSets::SegmentSet

      def earliest
        nil
      end

      def latest
        nil
      end

      def lexeme
        case Emendate.options.unknown_date_output
        when :orig
          sources.orig_string
        else
          Emendate.options.unknown_date_output_string
        end
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
