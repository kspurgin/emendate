# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module Collectionspace
      class Untokenizable < Emendate::Translators::Abstract
        private

        def translate_value
          base_value
        end
      end
    end
  end
end
