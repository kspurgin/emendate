# frozen_string_literal: true

module Emendate
  # Methods returning information about segments in a {SegmentSet},
  # mainly for use in manipulating the set
  module SegmentSetQueryable
    # @param seg [Segment]
    # @return [Segment, nil] the {Segment} before given seg, if any
    def previous_segment(seg)
      return nil if is_first_seg?(seg)

      segments[index_of(seg) - 1]
    end

    # @param seg [Segment]
    # @return [Segment, nil] the {Segment} after given seg, if any
    def next_segment(seg) = segments[index_of(seg) + 1]

    # @param seg [Segment]
    # @return [SegmentSet] all {Segment}s before given seg, if any
    def segments_before(seg)
      Emendate::SegmentSet.new(segments: first(index_of(seg)))
    end

    # @param seg [Segment]
    # @return [SegmentSet] all {Segment}s before given seg, if any
    def segments_after(seg)
      segs = segments[(index_of(seg) + 1)..-1]
      Emendate::SegmentSet.new(segments: segs)
    end

    # Retrieve the first series of {Segment}s matching the given
    # pattern, with the given sep inserted between each element of the
    # pattern. Allows to flexibly match day/month/year, month/day/year, etc.
    # patterns with different separators
    # @param pattern [Array<Symbol>]
    # @param sep [Symbol]
    # @return [SegmentSet] if resulting pattern matches
    # @return [nil] otherwise
    # @example When pattern matches the working result
    #   extract_pattern_separated_by(%i[number1or2 number1or2 number4], :slash)
    #   #=> #<Emendate::SegmentSet:6120
    #         segments: [:number1or2, :slash, :number1or2, :slash, :number4]>
    def segments_by_separated_pattern(pattern, sep)
      matching = extract(pattern.flat_map { |seg| [seg, sep] }[0..-2])
      matching unless matching.empty?
    end

    # Behaves the same as {#segments_by_separated_pattern}, but returns the
    #   Range representing the matching segments
    # @param pattern [Array<Symbol>]
    # @param sep [Symbol]
    # @return [Range] if resulting pattern matches
    # @return [nil] otherwise
    def range_matching_separated_pattern(pattern, sep)
      matches = segments_by_separated_pattern(pattern, sep)
      return unless matches

      Range.new(index_of(matches[0]), index_of(matches[-1]))
    end

    # @param seg [Emendate::Segment]
    # @param range [Range]
    # @return [Boolean]
    def not_in_range?(seg, range)
      !(range === index_of(seg))
    end

    # @param seg [Emendate::Segment]
    # @return [Boolean] whether given {Segment} can be collapsed backward

    def backward_collapsible?(seg) = !is_first_seg?(seg)

    # @param seg [Emendate::Segment]
    # @return [Boolean] whether given {Segment} can be collapsed forward
    def forward_collapsible?(seg) = !is_last_seg?(seg)

    # @param seg [Emendate::Segment]
    # @return [Boolean]
    def is_first_seg?(seg) = index_of(seg) == 0

    # @param seg [Emendate::Segment]
    # @return [Boolean]
    def is_last_seg?(seg) = index_of(seg) == (segments.length - 1)

    # @param type [Symbol] segment type to extract consecutive instances of
    # @return [Emendate::SegmentSet] whose segments are the first sequence of
    #   segments having the given type
    def consecutive_of_type(type)
      consec = []
      segments.each_cons(2) do |arr|
        same_type = arr.map(&:type).uniq == [type]
        break if !consec.empty? && !same_type

        consec << arr if same_type
      end
      return self.class.new if consec.empty?

      self.class.new(segments: consec.flatten!.uniq!)
    end

    # @param seg [Emendate::Segment]
    # @return [Integer]
    def index_of(seg)
      find_index(seg)
    end

    # @param seg [Emendate::Segment]
    # @param dir [:next, :prev]
    # @return [Integer] index after given {Segment} when dir is :next; index
    #   before given {Segment} when dir is :prev
    def ins_pt(seg, dir = :next)
      case dir
      when :next then find_index(seg) + 1
      when :prev then find_index(seg)
      else raise Emendate::Error, "dir must be :next or :prev"
      end
    end
  end
end
