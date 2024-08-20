# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module Collectionspace
      class KnownUnknown < Emendate::Translators::Abstract
        private

        def translate_value
          category = case date.source.category
          when :unknown_date then "Unknown"
          when :no_date then "No date"
          end

          @base = base_value.merge({dateEarliestSingleCertainty: category})
        end
      end
    end
  end
end
