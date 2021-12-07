# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Edtf
    # EDTF translator for YearMonth
      class YearMonth  < Emendate::Translators::Abstract
        private

        attr_reader :base
        
        def translate_value
          @date = tokens[0]
          @base = "#{@date.earliest.year}-#{@date.earliest.month}"
          qualify
        end
      end
    end
  end
end
