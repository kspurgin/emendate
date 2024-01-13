# frozen_string_literal: true

require "emendate/segment/token"
require "emendate/segment/derived_segment"

module Emendate
  # A token derived from another Token or Tokens
  # Usage:
  # rubocop:todo Layout/LineLength
  # Emendate::DerivedToken.new(type: :token_type, sources: [array of source tokens])
  # rubocop:enable Layout/LineLength
  class DerivedToken < Emendate::Token
    include DerivedSegment

    private

    def post_initialize(opts)
      derive(opts)
    end
  end
end
