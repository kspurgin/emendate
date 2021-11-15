# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Edtf
    # EDTF translator
      class Year  < Emendate::Translators::Abstract
        private

        def translate_value
          yr = processed.tokens[0]
          value = yr.lexeme
          return value if yr.certainty.empty?
        end
      end
    end
  end
end
