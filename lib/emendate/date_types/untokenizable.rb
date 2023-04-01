# frozen_string_literal: true

module Emendate
  module DateTypes
    # Represents a date string that is cannot be successfully tokenized.
    #
    # The purpose of treating this as a date type is to fail fast, gracefully,
    #   and informatively
    #
    # Created by {Emendate::UntokenizableTagger}
   class Untokenizable < Emendate::DateTypes::DateType

      # Expect to be initialized with:
      #   sources: Emendate::SegmentSets::SegmentSet

     include ErrorTypeable
    end
  end
end
