# frozen_string_literal: true

require_relative 'abstract'

module Emendate
  module Translators
    # LYRASIS pseudo EDTF translator
    class LyrasisPseudoEdtf < Emendate::Translators::Abstract
      private

      def empty_value
        ''
      end
    end
  end
end

