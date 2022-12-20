# frozen_string_literal: true

require 'forwardable'
require_relative 'certainty_helpers'
require_relative '../location'

module Emendate
  module SegmentSets
    class SegmentSet
      include Emendate::SegmentSets::CertaintyHelpers
      extend Forwardable
      attr_reader :orig_string, :segments,
        :certainty, :inferred_date, :warnings

      def_delegator :@segments, :[], :[]
      def_delegators :@segments, :clear, :delete, :delete_at, :empty?,
        :find_index, :first, :insert, :last, :length, :pop, :shift, :unshift

      def initialize(string: nil, segments: nil)
        @orig_string = string
        @segments = segments ? Array.new(segments) : Array.new
        @certainty = []
        @inferred_date = false
        @warnings = []
      end

      def <<(segment)
        segments << segment
      end

      def add_certainty(val)
        @certainty << val
        @certainty = certainty.flatten.uniq.sort
      end

      def copy(other_set)
        @orig_string = other_set.orig_string
        other_set.segments.each{ |s| segments << s.dup }
        other_set.certainty.each{ |c| @certainty << c.dup }
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

      def lexeme
        return '' if @segments.empty?

        @segments.map(&:lexeme).join
      end

      def location
        return Emendate::Location.new(0, 0) if @segments.empty?

        locs = @segments.map(&:location).sort_by(&:col)
        col = locs.first.col
        length = locs.map(&:length).sum
        Emendate::Location.new(col, length)
      end

      # returns the first sequence of segments matching the pattern of types
      #   passed in as an Array
      def extract(*args)
        args.flatten!
        segsize = args.length

        return self.class.new if segments.length < segsize

        if segments.length == segsize
          result = self.class.new(segments: segments)
          return result
        end

        tails = segments.select{ |t| t.type == args[-1] }
        return self.class.new if tails.empty?

        segment = []
        tails.each do |tail|
          if segment.empty?
            tail_i = segments.find_index(tail)
            head_i = tail_i - segsize + 1
            seg = self.class.new(segments: segments[head_i..tail_i])
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
          self.class.new(segments: results)
        else
          results
        end
      end

      def select(*args, &block)
        results = segments.select(*args, &block)
        if results.any?{ |s| s.kind_of?(Emendate::Segment) }
          self.class.new(segments: results)
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
end
