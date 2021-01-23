# frozen_string_literal: true

module Emendate
  class TokenSet < Array
    def types
      self.map(&:type)
    end

    def type_string
      types.join(' ')
    end
  end
end
