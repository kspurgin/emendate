# frozen_string_literal: true

require_relative "abstract"

module Emendate
  module Translators
    # namespace for LYRASIS pseudo EDTF translators
    module LyrasisPseudoEdtf
      DIALECT_OPTIONS = {
        no_date_output: :custom,
        no_date_output_string: "no date",
        unknown_date_output: :custom,
        unknown_date_output_string: "unknown date"
      }

      def date
        pdate
      end

      def empty_value
        ""
      end

      def approximate
        "#{qualified} (approximate)"
      end

      def approximate_and_uncertain
        "#{qualified} (uncertain and approximate)"
      end

      def alternate_set
        "#{qualified} (single date in range)"
      end

      def inclusive_set
        "#{qualified} (entire range)"
      end
    end
  end
end
