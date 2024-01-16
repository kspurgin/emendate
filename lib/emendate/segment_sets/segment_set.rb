# frozen_string_literal: true

require "forwardable"
require_relative "certainty_helpers"

module Emendate
  module SegmentSets
    class SegmentSet
      include Emendate::SegmentSets::CertaintyHelpers
      extend Forwardable
      attr_reader :orig_string, :norm, :segments,
        :certainty, :inferred_date, :warnings

      # @return [:alternate, :inclusive, NilClass]
      attr_reader :set_type

      def_delegator :@segments, :[], :[]
      def_delegators :@segments, :any?, :clear, :delete, :delete_at, :empty?,
        :fill, :find, :find_index, :first, :insert, :last, :length, :pop,
        :shift, :unshift

      def initialize(string: nil, norm: nil, segments: nil)
        @orig_string = string
        @norm = norm
        @segments = segments ? Array.new(segments) : []
        @set_type = nil
        @certainty = []
        @inferred_date = false
        @warnings = []
        @lexeme_order = []
      end

      def <<(segment)
        segments << segment
      end

      def add_certainty(val)
        @certainty << val
        @certainty = certainty.flatten.uniq.sort
      end

      def add_set_type(val)
        @set_type = val
      end

      def clear_set_certainty
        certainty.delete(:all_of_set)
        certainty.delete(:one_of_set)
        certainty
      end

      def copy(other_set)
        @orig_string = other_set.orig_string
        @norm = other_set.norm
        other_set.segments.each { |s| segments << s.dup }
        @set_type = other_set.set_type
        other_set.certainty.each { |c| @certainty << c.dup }
        other_set.warnings.each { |w| warnings << w.dup }
        @inferred_date = other_set.inferred_date
        self
      end

      def date_parts
        segments.select { |t| t.date_part? }
      end

      def date_part_types
        date_parts.map(&:type)
      end

      def date_part_type_string
        date_part_types.join(" ")
      end

      def each(...)
        segments.each(...)
      end

      def is_inferred
        @inferred_date = true
      end

      def lexeme
        return "" if segments.empty?

        segments.map(&:lexeme).join
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

        tails = segments.select { |t| t.type == args[-1] }
        return self.class.new if tails.empty?

        segment = []
        tails.each do |tail|
          next unless segment.empty?

          tail_i = segments.find_index(tail)
          head_i = tail_i - segsize + 1
          seg = self.class.new(segments: segments[head_i..tail_i])
          segment = (seg.types == args) ? seg : []
        end
        result = self.class.new
        segment.each { |s| result << s }
        result
      end

      def map(*, &block)
        results = segments.map(*, &block)
        if results.any? { |s| s.is_a?(Emendate::Segment) }
          self.class.new(segments: results)
        else
          results
        end
      end

      def select(*, &block)
        results = segments.select(*, &block)
        if results.any? { |s| s.is_a?(Emendate::Segment) }
          self.class.new(segments: results)
        else
          results
        end
      end

      def to_s
        <<~OBJ
          #<#{self.class.name}:#{object_id}
            @orig_string=#{orig_string.inspect},
            @norm=#{norm.inspect},
            segments: #{types.inspect},
            @certainty: #{certainty.inspect},
            @inferred_date: #{inferred_date},
            @warnings: #{warnings.inspect}>
        OBJ
      end
      alias_method :inspect, :to_s

      def types
        segments.map(&:type)
      end

      def type_string = types.join(" ")

      def source_types
        segments
          .map { |seg| seg.sources || seg }
          .map { |obj| obj.respond_to?(:types) ? obj.types : obj.type }
          .flatten
      end

      def source_type_string = source_types.join(" ")

      def when_type(type)
        segments.select { |t| t.type == type }
      end
    end
  end
end
