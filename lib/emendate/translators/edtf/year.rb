# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Edtf
    # EDTF translator
      class Year  < Emendate::Translators::Abstract
        private

        attr_reader :yr
        
        def translate_value
          @yr = processed.tokens[0]
          return certain_year if yr.certain?
        end

        def certain_year
          yr.lexeme
        end
      end
    end
  end
end
