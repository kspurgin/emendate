# frozen_string_literal: true

require 'emendate/segment'

module Emendate
  class DatePart < Emendate::Segment
    extend Forwardable

    attr_reader :source_tokens

    def post_initialize(opts)
      @source_token = opts[:source_tokens] || default_source_tokens
    end

    private

    def default_source_tokens
      Emendate::TokenSet.new
    end
  end
end
