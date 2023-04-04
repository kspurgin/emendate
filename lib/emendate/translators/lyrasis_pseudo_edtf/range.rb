# frozen_string_literal: true

require_relative '../abstract'

module Emendate
  module Translators
    module LyrasisPseudoEdtf
    # EDTF translator
      class Range  < Emendate::Translators::Abstract
        private

        attr_reader :base

        def translate_value
          range = date.source
          start = range.startdate
          enddate = range.enddate
          @base = "#{start.earliest_at_granularity} - "\
            "#{enddate.latest_at_granularity}"
          qualify
        end
      end
    end
  end
end
