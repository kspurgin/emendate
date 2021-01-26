# frozen_string_literal: true

module Emendate
  class TokenSet < Array
    def date_parts
      self.select{ |t| Emendate::DATE_PART_TOKEN_TYPES.include?(t.type) }
    end

    def date_part_types
      date_parts.map(&:type)
    end

    def date_part_type_string
      date_part_types.join(' ')
    end

    def types
      self.map(&:type)
    end

    def type_string
      types.join(' ')
    end
  end
end
