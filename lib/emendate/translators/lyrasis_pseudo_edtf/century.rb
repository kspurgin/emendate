# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module LyrasisPseudoEdtf
    # Lyrasis Pseudo-EDTF translator for century
      class Century  < Emendate::Translators::Abstract
        private

        attr_reader :base

        def translate_value
          century = date.source
          @base = "#{century.earliest_at_granularity} - "\
            "#{century.latest_at_granularity}"
          qualify(:one_of_range_set)
        end
      end
    end
  end
end
