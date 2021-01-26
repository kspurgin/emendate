# frozen_string_literal: true

require 'forwardable'

module Emendate
  class TokenTypeError < StandardError; end
  class TokenLexemeError < StandardError; end
  
  class Token
    extend Forwardable

    attr_reader :type, :lexeme, :literal, :location
    def_delegators :@location, :col, :length

    def initialize(type:, lexeme:, literal: nil, location:)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @location = location
    end

    def to_s
      "#{type} #{lexeme} #{literal}"
    end
  end

  class NumberToken < Token
    attr_reader :digits
    def initialize(**args)
      super(**args)

      unless type == :number
        raise Emendate::TokenTypeError.new('Number token must be created with type = :number')
      end

      unless lexeme.match?(/^\d+$/)
        raise Emendate::TokenLexemeError.new('Number token must be created with lexeme containing only numeric digits')
      end
      
      @digits = lexeme.length

      if allowed_digits?
        @type = digits <= 2 ? :number1or2 : "number#{digits}".to_sym
      else
        @type = :unknown
      end
      @literal = lexeme.to_i
    end

    private

    def allowed_digits?
      [1, 2, 3, 4, 6, 8].include?(digits) ? true : false
    end
  end
end
