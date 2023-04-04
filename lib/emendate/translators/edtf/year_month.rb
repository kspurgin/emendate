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
          @base = "#{date.source.earliest.year}-"\
            "#{date.source.earliest.month.to_s.rjust(2, '0')}"
          qualify
        end
      end
    end
  end
end
