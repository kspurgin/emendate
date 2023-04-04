# frozen_string_literal: true

module Emendate
  # Composite result class to compile translations of individual parsed
  #   dates for a string
  class Translation
    attr_reader :orig, :values, :warnings

    def initialize(orig:, values: [], warnings: [])
      @orig = orig
      @values = values
      @warnings = warnings
    end

    # @param value [Emendate::TranslatedDate]
    def add_value(value)
      @values << value.value
      @warnings << value.warnings
    end
  end
end
