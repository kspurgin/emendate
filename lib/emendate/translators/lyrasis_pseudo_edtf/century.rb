# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module LyrasisPseudoEdtf
      class Century < Emendate::Translators::Abstract
        private

        def translate_value
          @base = "#{date.earliest_at_granularity} - "\
                  "#{date.latest_at_granularity}"
          qualify
        end
      end
    end
  end
end
