# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module LyrasisPseudoEdtf
    # EDTF translator
      class Year  < Emendate::Translators::Abstract
        private

        attr_reader :base
        
        def translate_value
          @base = tokens[0].lexeme
          qualify
        end
      end
    end
  end
end
