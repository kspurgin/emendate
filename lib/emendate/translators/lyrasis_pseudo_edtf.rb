# frozen_string_literal: true

require_relative 'abstract'

module Emendate
  module Translators
    # namespace for LYRASIS pseudo EDTF translators
    module LyrasisPseudoEdtf
      def date
        pdate
      end

      def empty_value
        ''
      end

      def approximate
        "#{qualified} (approximate)"
      end

      def approximate_and_uncertain
        "#{qualified} (uncertain and approximate)"
      end

      def one_of_set
        "#{qualified} (exact year unspecified)"
      end
    end
  end
end
