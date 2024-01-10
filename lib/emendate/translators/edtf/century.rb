# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Edtf
      class Century < Emendate::Translators::Abstract
        private

        def translate_value
          century = date.source

          @base = "[#{century.earliest_at_granularity}" \
                  "..#{century.latest_at_granularity}]"
          qualify
        end
      end
    end
  end
end
