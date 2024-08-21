# frozen_string_literal: true

module Emendate
  # Consolidates the logic for returning subsources for {Segment},
  # {DateTypes::Range}, the other date type classes, and
  # {SegmentSet}
  module Subsourceable
    # @param as [:segset, :arr] how to return the subsources; for general use,
    #   pass no value and a {SegmentSet} will be returned. The :arr
    #   value is used in implementing the logic here, and can be used elsewhere
    #   in cases where you want a plain Array of {Segment}s instead of a
    #   {SegmentSet}
    # @return [Emendate::SegmentSet] if as: :segset
    # @return [Array<Emendate::Segment>] if as: :arr
    def subsources(as: :segset)
      result = subsource_segments.flatten
      return result unless as == :segset

      Emendate::SegmentSet.new(segments: result)
    end

    private

    def subsource_segments
      if respond_to?(:segments)
        subsource_segments_for_segment_set
      elsif instance_of?(Emendate::DateTypes::Range)
        subsource_segments_for_range
      elsif date_type?
        sources.subsources(as: :arr)
      elsif segment?
        subsource_segments_for_segment
      end
    end

    def subsource_segments_for_segment_set
      segments.map { |seg| seg.subsources(as: :arr) }
        .flatten
    end

    def subsource_segments_for_range
      [
        startdate.subsources(as: :arr),
        sources[1].subsources(as: :arr),
        enddate.subsources(as: :arr)
      ].flatten
        .map { |seg| seg.subsources(as: :arr) }
        .flatten
    end

    def subsource_segments_for_segment
      return [self] if sources.nil? || sources.empty?

      sources.map { |src| segment_subsources(src) }
    end

    def segment_subsources(src)
      return [src] if src.sources.nil? || src.sources.empty?

      src.subsources(as: :arr)
    end
  end
end
