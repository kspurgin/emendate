# frozen_string_literal: true

module Emendate
  class Translation
    attr_reader :orig, :value, :warnings

    def initialize(orig:, value:, warnings:)
      @orig, @value, @warnings = orig, value, warnings
    end
  end
end
