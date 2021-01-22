# frozen_string_literal: true

module Emendate
  class TokenSet < Array
    def types
      @tokens.map(&:type)
    end

    def type_string
      types.join(' ')
    end
  end
end
