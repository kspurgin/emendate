# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module LyrasisPseudoEdtf
      class KnownUnknown  < Emendate::Translators::Abstract
        private

        attr_reader :base

        def translate_value
          case Emendate.options.unknown_date_output
          when :custom
            Emendate.options.unknown_date_output_string
          else
            date.original_string
          end
        end
      end
    end
  end
end
