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

    def map
      arr = super
      if arr.any?{ |s| s.kind_of?(Emendate::Segment) }
        new = self.clone.clear
        arr.each{ |e| new << e }
        new
      else
        arr
      end
    end

    def types
      self.map(&:type)
    end

    def type_string
      types.join(' ')
    end

    def when_type(type)
      self.select{ |t| t.type == type }
    end
  end
end
