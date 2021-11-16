# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module LyrasisPseudoEdtf
    # EDTF translator
      class KnownUnknown  < Emendate::Translators::Abstract
        private

        attr_reader :base
        
        def translate_value
          @base = tokens[0].lexeme

          return base
        end
      end
    end
  end
end
