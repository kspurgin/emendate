# frozen_string_literal: true

require 'forwardable'
require 'emendate/segment/segment'

module Emendate
  class TokenTypeError < StandardError; end
  class TokenLexemeError < StandardError; end

  class Token < Emendate::Segment
    extend Forwardable

    attr_reader :location

    def_delegators :@location, :col, :length

    COLLAPSIBLE_TOKEN_TYPES = %i[space single_dot]
    DATE_PART_TOKEN_TYPES = %i[number1or2 number3 number4 number6 number8 s century
                               uncertainty_digits era number_month]

    def collapsible?
      COLLAPSIBLE_TOKEN_TYPES.include?(type)
    end

    def date_part?
      DATE_PART_TOKEN_TYPES.include?(type)
    end

    private

    def post_initialize(opts)
      @location = opts[:location]
    end
  end
end
