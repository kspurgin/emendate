# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module LyrasisPseudoEdtf
      class Range < Emendate::Translators::Abstract
        private

        def translate_value
          range = date.source
          @base = "#{get_str(range.startdate, :start)} - "\
            "#{get_str(range.enddate, :end)}"
          qualify
        end

        def get_str(date, pos)
          if date.is_a?(Emendate::DateTypes::RangeDateUnknownOrOpen)
            "#{date.category} date"
          else
            case pos
            when :start then date.earliest_at_granularity
            when :end then date.latest_at_granularity
            end
          end
        end
      end
    end
  end
end
