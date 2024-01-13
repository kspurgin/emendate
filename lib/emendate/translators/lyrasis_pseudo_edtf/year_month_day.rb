# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module LyrasisPseudoEdtf
      class YearMonthDay < Emendate::Translators::Abstract
        private

        def translate_value
          @base = "#{date.earliest.year}-"\
                  "#{date.earliest.month.to_s.rjust(2, "0")}-"\
                  "#{date.earliest.day.to_s.rjust(2, "0")}"
          qualify
        end
      end
    end
  end
end
