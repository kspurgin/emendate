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

    # returns the first sequence of segments matching the pattern of types passed in 
    def extract(*args)
      args.flatten!
      segsize = args.length
      return self.dup.clear if self.length < segsize
      return self.dup if self.length == segsize
      
      tails = self.select{ |t| t.type == args[-1] }
      return self.dup.clear if tails.empty?

      segment = []
      tails.each do |tail|
        if segment.empty?
          tail_i = self.find_index(tail)
          head_i = tail_i - segsize + 1
          seg = self[head_i..tail_i]
          segment = seg if seg.types == args
        end
      end
      segment.dup
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
