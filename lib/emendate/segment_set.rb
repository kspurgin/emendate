# frozen_string_literal: true

require "forwardable"
require_relative "segment_set_editable"
require_relative "segment_set_queryable"
require_relative "subsourceable"

module Emendate
  # @todo Get rid of norm
  class SegmentSet
    include Comparable
    include SegmentSetEditable
    include SegmentSetQueryable
    include Subsourceable
    extend Forwardable

    attr_reader :orig_string, :norm, :segments,
      :inferred_date, :warnings

    # @return [Array<Emendate::Qualifier>]
    attr_reader :qualifiers

    # @!macro [new] set_type_attr
    #   @return [:alternate, :inclusive, nil]
    attr_reader :set_type

    def_delegator :@segments, :[], :[]
    def_delegators :@segments, :any?, :clear, :delete, :delete_at, :empty?,
      :fill, :find, :find_index, :first, :insert, :last, :length, :pop,
      :reject, :reject!, :reverse_each, :shift, :unshift

    def initialize(string: nil, norm: nil, segments: nil)
      @orig_string = string
      @norm = norm
      @segments = segments ? Array.new(segments) : []
      @set_type = nil
      @qualifiers = []
      @inferred_date = false
      @warnings = []
    end

    def <<(segment)
      segments << segment
    end

    # @param qual [Emendate::Qualifier]
    def add_qualifier(qual)
      unless qual.is_a?(Emendate::Qualifier)
        raise Emendate::QualifierTypeError
      end

      qualifiers << qual
    end

    # @param val [Symbol]
    def add_set_type(val)
      @set_type = val
    end

    def add_warning(warning)
      warnings << warning
    end

    # @return [Boolean]
    def any_unprocessed? = segments.map(&:processed?).include?(false)

    # @return [Array<Emendate::Segment>]
    def unprocessed
      segments.select { |seg| !seg.processed? }
    end

    # @param other_set [Emendate::SegmentSet]
    def copy(other_set)
      @orig_string = other_set.orig_string
      @norm = other_set.norm
      other_set.segments.each { |s| segments << s.dup }
      @set_type = other_set.set_type
      other_set.qualifiers.each { |q| @qualifiers << q }
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

    # @param types [Array<Symbol>] pattern of types of the segments you wish
    #   to extract
    # @return [Emendate::SegmentSet] the first sequence of
    #   segments matching the pattern of types passed in
    def extract(*types)
      types.flatten!
      segsize = types.length
      return self.class.new if segments.length < segsize
      return self.class.new(segments: segments) if segments.length == segsize

      slice = segments.select { |seg| seg.type == types[0] }
        .map { |seg| take_slice(seg, types) }
        .compact
        .first
      return self.class.new unless slice

      result = self.class.new
      slice.each { |s| result << s }
      result
    end

    # Extracts the first instance of the given date part pattern, plus any
    # non-date part segments in between the beginning and ending date parts
    # @param types [Array<Symbol>] pattern of types of the date part
    #   segments you wish to extract
    # @return [Emendate::SegmentSet] the first sequence of
    #   segments matching the pattern of types passed in
    def extract_by_date_part(*types)
      types.flatten!
      slice = date_part_types.map
        .with_index { |type, ind| (type == types[0]) ? ind : nil }
        .compact
        .map { |ind| date_parts[Range.new(ind, ind + types.length - 1)] }
        .map { |segs| take_date_part_slice(segs) }
        .first

      result = self.class.new
      slice.each { |s| result << s }
      result
    end

    # @param type [Symbol] to extract
    # @return [Array<Emendate::Segment>] matching type
    def when_type(type)
      segments.select { |t| t.type == type }
    end

    # @return [Emendate::SegmentSet] if result includes
    #   {Emendate::Segment}s
    # @return [Array] otherwise
    def map(*, &block)
      results = segments.map(*, &block)
      if results.any? { |s| s.is_a?(Emendate::Segment) }
        self.class.new(segments: results)
      else
        results
      end
    end

    # @return [Emendate::SegmentSet] all segments meeting
    #   criteria passed in block
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
          @qualifiers: #{qualifiers.inspect},
          @set_type: #{set_type.inspect},
          @inferred_date: #{inferred_date},
          @warnings: #{warnings.inspect}>
      OBJ
    end
    alias_method :inspect, :to_s

    def <=>(other)
      return unless other.is_a?(self.class)

      signature <=> other.signature
    end

    def eql?(other) = self.class == other.class && self == other

    def signature
      segments.map(&:hash).flatten.join("|")
    end

    def hash = signature.hash

    # The types of the segments currently in the segment set
    # @return [Array<Symbol>]
    def types
      segments.map(&:type)
    end

    # The types of the segments currently in the segment set, as a string
    # @return [String]
    def type_string = types.join(" ")

    # The types of all immediate sources of the segments currently in the
    # segment set. That is, the top-level sources of each current segment
    # are listed.
    # @return [Array<Symbol>]
    def source_types
      segments
        .map { |seg| seg.sources || seg }
        .map { |obj| obj.respond_to?(:types) ? obj.types : obj.type }
        .flatten
    end

    # Source types, as described in {#source_types}, as a string
    # @return [String]
    def source_type_string = source_types.join(" ")

    # The types of all segments which have been combined to arrive at the
    # current segment set. This provides all the sources of all the derived
    # segments in one flat list, regardless of how many levels of derivation
    # have occurred.
    # @return [Array<Symbol>]
    def subsource_types
      subsources.types
    end

    # Subsource types, as described in {#subsource_types}, as a string
    # @return [String]
    def subsource_type_string = subsource_types.join(" ")

    private

    def take_slice(seg, types)
      slice = segments.slice(segments.find_index(seg), types.length)
      slice if slice.map(&:type) == types
    end

    def take_date_part_slice(segs)
      inds = [segs.first, segs.last].map { |seg| segments.find_index(seg) }
      segments[Range.new(inds.first, inds.last)]
    end
  end
end
