# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module LyrasisPseudoEdtf
      class Range < Emendate::Translators::Abstract
        private

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
