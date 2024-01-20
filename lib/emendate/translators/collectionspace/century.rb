# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module Collectionspace
      class Century < Emendate::Translators::Abstract
        private

        def translate_value
          @base = computed
          qualify
        end

        def qualify_set = qualified
      end
    end
  end
end
