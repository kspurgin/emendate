# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module Collectionspace
      class Year < Emendate::Translators::Abstract
        private

        def translate_value
          @base = computed
          qualify
        end
      end
    end
  end
end
