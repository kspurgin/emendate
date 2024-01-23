# frozen_string_literal: true

module Emendate
  class EdtfSetHandler
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = tokens.class.new.copy(tokens)
    end

    def call
      return Success(result) unless alternate_set? || inclusive_set?

      if alternate_set?
        _alt = yield handle_set(:alternate)
      elsif inclusive_set?
        _inc = yield handle_set(:inclusive)
      end

      Success(result)
    end

    private

    attr_reader :result, :working

    def alternate_set?
      edtf_square_brackets? && square_bracket_wrapped?
    end

    def edtf_square_brackets?
      Emendate.options.square_bracket_interpretation == :edtf_set
    end

    def square_bracket_wrapped?
      result.types.first == :square_bracket_open &&
        result.types.last == :square_bracket_close
    end

    def inclusive_set?
      result.types.first == :curly_bracket_open &&
        result.types.last == :curly_bracket_close
    end

    def handle_set(type)
      return Failure(:invalid_edtf_set) unless inner_valid?

      result.add_set_type(type)
      result.collapse_enclosing_tokens
      Success()
    end

    def inner_valid?
      allowed = %i[number3 number4 number1or2 comma double_dot hyphen]

      result.types[1..-2].all? { |type| allowed.include?(type) }
    end
  end
end
