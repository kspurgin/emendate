# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Edtf
    # EDTF translator
      class KnownUnknown  < Emendate::Translators::Abstract
        private
        
        def translate_value
          'XXXX'
        end
      end
    end
  end
end
