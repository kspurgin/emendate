# frozen_string_literal: true

module Emendate
  # Composite result class to compile translations of individual parsed
  #   dates for a string
  class Translation
    attr_reader :pm, :orig, :parsed, :values, :warnings

    # @param pm [Emendate::ProcessingManager] to support debugging
    def initialize(pm:)
      @pm = pm
      @orig = pm.orig_string
      @parsed = pm.result.dates
      @values = []
      @warnings = []
    end

    # @param value [Emendate::TranslatedDate]
    def add_value(value)
      @values << value.value
      @warnings << value.warnings
    end
  end
end
