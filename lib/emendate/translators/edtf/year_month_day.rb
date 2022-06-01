# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Edtf
    # EDTF translator for YearMonthDay
      class YearMonthDay  < Emendate::Translators::Abstract
        private

        attr_reader :base
        
        def translate_value
          @date = tokens[0]
          @base = "#{@date.earliest.year}-#{@date.earliest.month.to_s.rjust(2, '0')}-#{@date.earliest.day.to_s.rjust(2, '0')}"
          qualify
        end
      end
    end
  end
end
