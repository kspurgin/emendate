# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Edtf
    # EDTF translator for century
      class Century  < Emendate::Translators::Abstract
        private

        attr_reader :base
        
        def translate_value
          @century = tokens[0]
          @base = "#{@century.earliest_at_granularity}..#{@century.latest_at_granularity}"
          qualify(:one_of_range_set)
        end
      end
    end
  end
end
