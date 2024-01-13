# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module Collectionspace
      class ProcessingError < Emendate::Translators::Abstract
        private

        def translate_value
          warnings << "Processing error"
          processed.errors.each { |err| warnings << err }
          base_value
        end
      end
    end
  end
end
