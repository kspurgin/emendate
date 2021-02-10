# frozen_string_literal: true

require 'forwardable'

module Emendate
  # Tokens, tagged date parts, tagged dates are subclasses of Segment
  class Segment

    attr_reader :type, :lexeme, :literal

    def initialize(**opts)
      @type = opts[:type]
      @lexeme = opts[:lexeme]
      @literal = opts[:literal] || default_literal

      post_initialize(opts)
    end

    def to_s
      "#{type} #{lexeme} #{literal}"
    end

    private

    # subclasses can override this empty method
    def post_initialize(opts)
    end
    
    def default_literal
      nil
    end
  end
end
