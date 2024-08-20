# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module LyrasisPseudoEdtf
      class KnownUnknown < Emendate::Translators::Abstract
        private

        def translate_value
          @base = case date.source.category
          when :no_date
            Emendate.options.no_date_output_string
          when :unknown_date
            Emendate.options.unknown_date_output_string
          end
        end
      end
    end
  end
end
