# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Edtf
      class YearMonthDay < Emendate::Translators::Abstract
        private

        def translate_value
          src = date.source
          @base = "#{src.earliest.year}-" \
                  "#{src.earliest.month.to_s.rjust(2, '0')}-" \
                  "#{src.earliest.day.to_s.rjust(2, '0')}"
          qualify
        end
      end
    end
  end
end
