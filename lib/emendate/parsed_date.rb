# frozen_string_literal: true

module Emendate
  class ParsedDate

    attr_reader :orig

    def initialize(orig:)
      @orig = orig
    end
  end
end
