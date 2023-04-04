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
        "#{base} (approximate)"
      end

      def approximate_and_uncertain
        "#{base} (uncertain and approximate)"
      end

      def one_of_range_set
        "#{base} (exact year unspecified)"
      end
    end
  end
end
