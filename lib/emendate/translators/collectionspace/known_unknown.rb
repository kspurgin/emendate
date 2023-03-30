# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Collectionspace
      class KnownUnknown  < Emendate::Translators::Abstract
        private

        def translate_value
          nil_value
        end
      end
    end
  end
end
