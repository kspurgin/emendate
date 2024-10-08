# frozen_string_literal: true

module Emendate
  # Composite result class to compile translations of individual parsed
  #   dates for a string
  class Translation
    attr_reader :pm, :orig, :parsed, :values

    # @param pm [Emendate::ProcessingManager] to support debugging
    def initialize(pm:)
      @pm = pm
      @orig = pm.orig_string
      @parsed = pm.result.dates
      @values = []
      @warnings = []
      set_initial_warnings
    end

    # @param value [Emendate::TranslatedDate]
    def add_value(value)
      @values << value.value
      @warnings << value.warnings
    end

    def warnings
      @warnings.unshift("No dates parsed from string") if values.empty?
      @warnings.flatten.uniq
    end

    def add_warning(value) = @warnings << value

    private

    def set_initial_warnings
      set_warnings_from_pm_errors
      set_warnings_from_pm_warnings
    end

    def set_warnings_from_pm_errors
      pm.errors.each { |err| @warnings << err_string(err) }
    end

    def err_string(err)
      prefix = "DATE PARSE ERROR: "
      return "#{prefix}#{err}" unless err.respond_to?(:backtrace)

      "#{prefix}#{err.message}: #{err.backtrace[0]}"
    end

    def set_warnings_from_pm_warnings
      pm.warnings.each { |wrn| @warnings << wrn }
    end
  end
end
