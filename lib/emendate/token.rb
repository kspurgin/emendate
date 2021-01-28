# frozen_string_literal: true

require 'forwardable'
require 'emendate/segment'

module Emendate
  class TokenTypeError < StandardError; end
  class TokenLexemeError < StandardError; end
  
  class Token < Emendate::Segment
    extend Forwardable

    attr_reader :location
    def_delegators :@location, :col, :length

    def post_initialize(opts)
      @location = opts[:location]
    end
  end
end
