# frozen_string_literal: true

module Emendate
  module DateTypes
    # Represents a date string that is successfully tokenized, but that is known
    #  not to currently be processable by the application.
    #
    # The purpose of treating this as a date type is to fail fast, gracefully,
    #   and informatively
    #
    # Created by {Emendate::UnprocessableTagger}, based on a list of regular
    #   expressions for known unsupported date patterns
    class Unprocessable < Emendate::DateTypes::DateType

      # Expect to be initialized with:
      #   sources: Emendate::SegmentSets::SegmentSet

      include ErrorTypeable
    end
  end
end
