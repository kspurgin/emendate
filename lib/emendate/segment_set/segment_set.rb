# frozen_string_literal: true

require 'forwardable'

module Emendate
  class SegmentSet
    extend Forwardable
    attr_reader :segments, :certainty, :inferred_date, :warnings

    def_delegator :@segments, :[], :[]
    def_delegators :@segments, :clear, :delete, :delete_at, :empty?, :find_index, :insert, :length, :pop, :shift

    def initialize(*args)
      @segments = Array.new(*args)
      @certainty = []
      @inferred_date = false
      @warnings = []
    end

    def <<(segment)
      segments << segment
    end

    def add_certainty(val)
      certainty << val
    end

    def copy(other_set)
      other_set.segments.each{ |s| segments << s.dup }
      other_set.certainty.each{ |c| certainty << c.dup }
      other_set.warnings.each{ |w| warnings << w.dup }
      @inferred_date = other_set.inferred_date
      self
    end

    def date_parts
      segments.select{ |t| t.date_part? }
    end

    def date_part_types
      date_parts.map(&:type)
    end

    def date_part_type_string
      date_part_types.join(' ')
    end

    def each(*args, &block)
      segments.each(*args, &block)
    end

    def is_inferred
      @inferred_date = true
    end


    # returns the first sequence of segments matching the pattern of types passed in as an Array
    def extract(*args)
      args.flatten!
      segsize = args.length

      return self.class.new if segments.length < segsize
      if segments.length == segsize
        result = self.class.new(segments)
        return result
      end

      tails = segments.select{ |t| t.type == args[-1] }
      return self.class.new if tails.empty?

      segment = []
      tails.each do |tail|
        if segment.empty?
          tail_i = segments.find_index(tail)
          head_i = tail_i - segsize + 1
          seg = self.class.new(segments[head_i..tail_i])
          segment = seg.types == args ? seg : []
        end
      end
      result = self.class.new
      segment.each{ |s| result << s }
      result
    end

    def map(*args, &block)
      results = segments.map(*args, &block)
      if results.any?{ |s| s.kind_of?(Emendate::Segment) }
        self.class.new(results)
      else
        results
      end
    end

    def select(*args, &block)
      results = segments.select(*args, &block)
      if results.any?{ |s| s.kind_of?(Emendate::Segment) }
        self.class.new(results)
      else
        results
      end
    end

    def types
      segments.map(&:type)
    end

    def type_string
      types.join(' ')
    end

    def when_type(type)
      segments.select{ |t| t.type == type }
    end
  end
end
