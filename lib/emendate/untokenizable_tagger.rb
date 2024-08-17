# frozen_string_literal: true

module Emendate
  # If :final_check_failure_handling option = :failure, returns a
  # single {Emendate::DateTypes::Error} with error type :untokenizble
  # if date string matches a known unsupported pattern
  #
  # If :final_check_failure_handling option = :collapse_unhandled or
  # :collapse_unhandled_first_date, tags untokenizable sequences as such
  # and sets warning, but does not fail.
  class UntokenizableTagger
    include Dry::Monads[:result]

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @tokens = tokens
      @result = tokens.class.new.copy(tokens)
      @failure_mode = Emendate.set_unhandled_mode
    end

    def call
      return Success(tokens) unless untokenizable?

      case failure_mode
      when :failure
        process_as_failure
      when :collapse_unhandled
        process_as_warning
      end
    end

    private

    attr_reader :tokens, :result, :failure_mode

    def process_as_failure
      result.clear
      result << Emendate::DateTypes::Error.new(
        error_type: :untokenizable,
        sources: tokens
      )
      add_warnings
      Failure(result)
    end

    def process_as_warning
      add_warnings
      Success(result)
    end

    def add_warnings
      result.warnings << "Untokenizable sequences: "\
        "#{untokenizable_strings.join("; ")}"
    end

    def untokenizable_strings
      tokens.select { |token| token.type == :unknown }.segments.map(&:lexeme)
    end

    def untokenizable?
      tokens.types.any?(:unknown)
    end
  end
end
