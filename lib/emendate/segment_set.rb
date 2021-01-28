# frozen_string_literal: true

module Emendate
  class SegmentSet < Array
    def date_parts
      self.select{ |t| t.date_part? }
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
