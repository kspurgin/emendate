# frozen_string_literal: true

require_relative 'abstract'

module Emendate
  module Translators
    # namespace for LYRASIS pseudo EDTF translators
    module LyrasisPseudoEdtf
      def empty_value
        ''
      end
      
      def approximate
        "#{base} (approximate)"
      end

      def approximate_and_uncertain
        "#{base} (uncertain and approximate)"
      end
    end
  end
end

