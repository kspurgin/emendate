# frozen_string_literal: true

module Emendate
  # Final handling tokens that are not part of actual date types.
  #
  # Initially, this only includes :date_separator tokens. If the whole lexeme
  # is needed at this stage, it should be accessed from :orig_string on the
  # result segment set. The lexeme of each date type should contain only the
  # orig_string part that expresses that date.
  class TokenCleaner
    include Dry::Monads[:result]

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @working = tokens.class.new.copy(tokens)
      @result = tokens.class.new.copy(tokens)
      result.clear
    end

    def call
      has_date_separator? ? handle_separator : passthrough_all
      Success(result)
    end

    private

    attr_reader :result, :working

    def delete_separator
      if current.type == :date_separator
        working.shift
      else
        passthrough
      end
    end

    def current
      working[0]
    end

    def handle_separator
      delete_separator until working.empty?
    end

    def has_date_separator?
      working.types.include?(:date_separator)
    end

    def nxt(n = 1)
      working[n]
    end

    def passthrough
      result << working.shift
    end

    def passthrough_all
      passthrough until working.empty?
    end
  end
end
