# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Collectionspace
      class Year  < Emendate::Translators::Abstract
        private

        attr_reader :base

        def translate_value
          @base = computed
          qualified = qualify

          if processed.tokens[0].era == :bce
            qualified.merge(
              {
                dateEarliestSingleEra: 'BCE',
                dateLatestEra: 'BCE'
              }
            )
          else
            qualified
          end
        end
      end
    end
  end
end
