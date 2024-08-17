# frozen_string_literal: true

module Emendate
  # Final handling of tokens that are not part of actual date types.
  #
  # If the whole lexeme is needed at this stage, it should be accessed
  # from :orig_string on the result segment set. The lexeme of each
  # date type should contain only the orig_string part that expresses
  # that date.
  class TokenCleaner
    include Dry::Monads[:result]

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = tokens.class.new.copy(tokens)
      @unhandled_mode = Emendate.set_unhandled_mode
    end

    def call
      return Success(result) unless cleaning_needed?

      handle_separator if has_date_separator?
      handle_unknown if has_unknown?
      return Success(result) unless unhandled_mode == :collapse_unhandled

      handle_unprocessed if result.any_unprocessed?
      Success(result)
    end

    private

    attr_reader :result, :unhandled_mode

    def cleaning_needed?
      return true if has_date_separator? || has_unknown?
      return true if unhandled_mode == :collapse_unhandled &&
        result.any_unprocessed?

      false
    end

    def has_date_separator? = result.types.include?(:date_separator)

    def handle_separator = result.reject! { |seg| seg.type == :date_separator }

    def has_unknown? = result.types.include?(:unknown)

    def handle_unknown = result.reject! { |seg| seg.type == :unknown }

    def handle_unprocessed
      details = result.unprocessed
        .map { |seg| "#{seg.type.inspect} (#{seg.lexeme})" }
        .join("; ")
      result.add_warning("Unhandled segments still present: #{details}")
      result.reject! { |seg| !seg.processed? }
    end
  end
end
