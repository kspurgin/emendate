# frozen_string_literal: true

module Emendate
  # Data class representing a translation of a single ParsedDate
  class TranslatedDate
    attr_reader :orig, :value

    def initialize(orig:, value:, warnings: [])
      @orig = orig
      @value = value
      @warnings = warnings
    end

    def warnings = @warnings.flatten.uniq
  end
end
