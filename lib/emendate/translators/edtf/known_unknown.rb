# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Edtf
      class KnownUnknown < Emendate::Translators::Abstract
        private

        def translate_value
          @base = 'XXXX'
        end
      end
    end
  end
end
