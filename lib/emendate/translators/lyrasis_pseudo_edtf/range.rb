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
          @range = tokens[0]
          @start = @range.startdate
          @end = @range.enddate
          @base = "#{@start.earliest_at_granularity} - #{@end.latest_at_granularity}"
          qualify
        end
      end
    end
  end
end
