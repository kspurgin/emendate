# frozen_string_literal: true

module Emendate
  # Methods used by {Emendate::PROCESSING_STEPS processing step} Objects to edit
  # the result they return. This is not the final result.
  # Classes including this module must have a `result` attr_reader
  module ResultEditable
    # rubocop:todo Layout/LineLength
    # derives a single token from 2 or more tokens, keeping the first token's type
    # rubocop:enable Layout/LineLength
    # @param ary [Array<Symbol>]
    def collapse_segments_backward(ary)
      segs = result.extract(ary).segments
      derived = Emendate::Segment.new(type: segs.first.type, sources: segs)
      replace_segments_with_new(segments: segs, new: derived)
    end

    # rubocop:todo Layout/LineLength
    # derives a single token from 2 or more tokens, keeping the final token's type
    # rubocop:enable Layout/LineLength
    # @param ary [Array<Symbol>]
    def collapse_segments_forward(ary)
      segs = result.extract(ary).segments
      derived = Emendate::Segment.new(type: segs.last.type, sources: segs)
      replace_segments_with_new(segments: segs, new: derived)
    end

    # derives a single token from two tokens, keeping the first token's type
    def collapse_token_pair_backward(s1, s2)
      new = Emendate::Segment.new(type: s1.type, sources: [s1, s2])
      replace_segments_with_new(segments: [s1, s2], new: new)
    end

    # derives a single token from two tokens, keeping the second token's type
    def collapse_token_pair_forward(s1, s2)
      new = Emendate::Segment.new(type: s2.type, sources: [s1, s2])
      replace_segments_with_new(segments: [s1, s2], new: new)
    end

    # @param s1 [Segment] first of pair
    # @param s2 [Segment] second of pair
    # @param direction [:forward, :backward]
    def collapse_token_pair(s1, s2, direction)
      case direction
      when :forward
        collapse_token_pair_forward(s1, s2)
      when :backward
        collapse_token_pair_backward(s1, s2)
      else
        raise Emendate::Error, "Direction must be :forward or :backward"
      end
    end

    # Finds all segments of the given type and collapses each in the given
    # direction
    # @param type [Symbol]
    # @param direction [:forward, :backward]
    def collapse_all_matching_type(type:, dir:, segs: nil)
      target = segs ||= result
      target.when_type(type)
        .reverse_each { |seg| collapse_segment(seg, dir) }
    end

    # Derive a single segment by collapsing the given segment into an adjacent
    # segment
    # @param seg [{Segment}] to collapse
    # @param dir [:forward, :backward] If :forward, the given segment
    #   is collapsed into the subsequent segment. The subsequent
    #   segment's type is retained in the new segment. If :backward,
    #   the given segment is collapsed into the previous segment. The
    #   previous segment's type is retained in the new segment.
    # @raise {Emendate::ImpossibleCollapseError} if you attempt to collapse the
    #   initial segment backward, or the final segment forward
    def collapse_segment(seg, dir)
      test = :"#{dir}_collapsible?"
      raise Emendate::ImpossibleCollapseError.new(dir) unless send(test, seg)

      target = target_by_direction(seg, dir)
      sources = case dir
      when :forward then [seg, target]
      when :backward then [target, seg]
      else raise Emendate::Error, "dir must be :forward or :backward"
      end
      new = Emendate::Segment.new(type: target.type, sources: sources)
      replace_segments_with_new(segments: sources, new: new)
    end

    # Derives a single token from the first and second tokens in the
    # result, keeping the second token's type
    def collapse_first_token
      collapse_token_pair_forward(result[0], result[1])
    end

    # Derives a single token from the last and next-to-last tokens in the
    # result, keeping the next-to-last token's type
    def collapse_last_token
      collapse_token_pair_backward(result[-2], result[-1])
    end

    # Collapses first and last tokens inward, keeping the types of the
    # tokens each is collapsed into. Convenience method for collapsing
    # extraneous parentheses, brackets, etc. around whole values.
    def collapse_enclosing_tokens
      collapse_first_token
      collapse_last_token
    end

    # @param old [Array<Symbol>] of segments to replace
    # @param new [Symbol] for new derived replacement
    def replace_segtypes_with_new_type(old:, new:)
      segments = result.extract(old)
      newsegment = Emendate::Segment.new(type: new, sources: segments)
      result.insert(ins_pt(segments[0]), newsegment)
      segments.each { |segment| result.delete(segment) }
    end

    # @param sources [Array<Emendate::Segment>]
    # @param date_part_type [Symbol]
    def replace_segs_with_new_type(segs:, type:)
      new = Emendate::Segment.new(type: type, sources: segs)
      result.insert(ins_pt(segs[0]), new)
      segs.each { |x| result.delete(x) }
    end

    # @param sources [Array<Emendate::Segment>] to replace
    # @param new [Emendate::Segment] replacement
    def replace_segments_with_new(segments:, new:)
      result.insert(ins_pt(segments[-1]), new)
      segments.each { |segment| result.delete(segment) }
    end

    # @param sources [Array<Emendate::Segment>] to replace
    # @param new [Emendate::SegmentSet] replacement
    def replace_segments_with_new_segment_set(segments:, new:)
      result.insert(ins_pt(segments[-1]), *new.segments)
      segments.each { |segment| result.delete(segment) }
      new.warnings.each { |warn| result.add_warning(warn) }
    end

    # @param x [Segment] to replace
    # @param type [Symbol] type of the new segment
    def replace_x_with_derived_new_type(x:, type:)
      newsegment = Emendate::Segment.new(type: type, sources: [x])
      replace_x_with_new(x: x, new: newsegment)
    end

    # @param x [Segment]
    # @param new [Segment]
    def replace_x_with_new(x:, new:)
      result.insert(ins_pt(x), new)
      result.delete(x)
    end

    # @param x [Emendate::Segment]
    # @param date_part_type [Symbol]
    def replace_x_with_date_part_type(x:, date_part_type:)
      replace_segs_with_new_type(segs: [x], type: date_part_type)
    end

    # @param seg [Emendate::Segment]
    # @return [Emendate::Segment, nil]
    def previous_segment(seg) = result[index_of(seg) - 1]

    # @param seg [Segment]
    # @return [Segment, nil]
    def next_segment(seg) = result[index_of(seg) + 1]

    # @param pattern [Array<Symbol>]
    # @param sep [Symbol]
    # @return [SegmentSet] if resulting pattern matches
    # @return [nil] otherwise
    # @example When pattern matches the working result
    #   extract_pattern_separated_by(%i[number1or2 number1or2 number4], :slash)
    #   #=> #<Emendate::SegmentSet:6120
    #         segments: [:number1or2, :slash, :number1or2, :slash, :number4]>
    def extract_pattern_separated_by(pattern, sep)
      newset = result.extract(pattern.flat_map { |seg| [seg, sep] }[0..-2])
      newset unless newset.empty?
    end

    # @param seg [Emendate::Segment]
    # @param dummytype [Symbol]
    def insert_dummy_after_segment(seg, dummytype)
      newsegment = Emendate::Segment.new(type: dummytype)
      result.insert(ins_pt(seg), newsegment)
    end

    private

    # @param seg [Emendate::Segment]
    # @param dir [:forward, :backward]
    # @return [Emendate::Segment]
    def target_by_direction(seg, dir)
      targetind = (dir == :forward) ? 1 : -1
      result[index_of(seg) + targetind]
    end

    # @param seg [Emendate::Segment]
    # @return [Boolean]
    def backward_collapsible?(seg) = !seg_first?(seg)

    # @param seg [Emendate::Segment]
    # @return [Boolean]
    def forward_collapsible?(seg) = !seg_last?(seg)

    # @param seg [Emendate::Segment]
    # @return [Boolean]
    def seg_first?(seg) = index_of(seg) == 0

    # @param seg [Emendate::Segment]
    # @return [Boolean]
    def seg_last?(seg) = index_of(seg) == (result.length - 1)

    # @param seg [Emendate::Segment]
    # @return [Integer]
    def index_of(seg)
      result.find_index(seg)
    end

    # @param seg [Emendate::Segment]
    # @param dir [:next, :prev]
    # @return [Integer] index after given segment
    def ins_pt(seg, dir = :next)
      case dir
      when :next then result.find_index(seg) + 1
      when :prev then result.find_index(seg) - 1
      else raise Emendate::Error, "dir must be :next or :prev"
      end
    end
  end
end
