# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module Collectionspace
      class YearMonth < Emendate::Translators::Abstract
        private

        attr_reader :base

        def translate_value
          @base = computed
          qualify
        end
      end
    end
  end
end
