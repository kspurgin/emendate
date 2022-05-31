# frozen_string_literal: true

require 'forwardable'

module Emendate
  # Tokens, tagged date parts, tagged dates are subclasses of Segment
  class Segment

    attr_reader :type, :lexeme, :literal, :certainty

    def initialize(**opts)
      @type = opts[:type]
      @lexeme = opts[:lexeme]
      @literal = opts[:literal] || default_literal
      @certainty = default_certainty
      post_initialize(opts)
    end

    def add_certainty(val)
      certainty << val
      certainty.flatten!
    end

    def collapsible?
      false
    end
    
    def date_type?
      false
    end

    def to_s
      "#{type} #{lexeme} #{literal}"
    end

    private

    # subclasses can override this empty method
    def post_initialize(opts)
    end

    def default_certainty
      []
    end

    def default_literal
      nil
    end
  end
end
