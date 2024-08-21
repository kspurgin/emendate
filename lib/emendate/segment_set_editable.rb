# frozen_string_literal: true

module Emendate
  # Methods for manipulating the segments in a {SegmentSet}
  module SegmentSetEditable
    # Derives a single token from 2 or more tokens, keeping the first token's
    # type
    # @param ary [Array<Symbol>]
    def collapse_segments_backward(ary)
      segs = extract(ary).segments
      derived = Emendate::Segment.new(type: segs.first.type, sources: segs)
      replace_segments_with_new(segs: segs, new: derived)
    end

    # Derives a single token from 2 or more tokens, keeping the final token's
    # type
    # @param ary [Array<Symbol>]
    def collapse_segments_forward(ary)
      segs = extract(ary).segments
      derived = Emendate::Segment.new(type: segs.last.type, sources: segs)
      replace_segments_with_new(segs: segs, new: derived)
    end

    # derives a single token from two tokens, keeping the first token's type
    def collapse_token_pair_backward(s1, s2)
      new = Emendate::Segment.new(type: s1.type, sources: [s1, s2])
      replace_segments_with_new(segs: [s1, s2], new: new)
    end

    # derives a single token from two tokens, keeping the second token's type
    def collapse_token_pair_forward(s1, s2)
      new = Emendate::Segment.new(type: s2.type, sources: [s1, s2])
      replace_segments_with_new(segs: [s1, s2], new: new)
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
    # @param range [Range] if given, only the {Segment}s falling in this
    #   range will be collapsed
    def collapse_all_matching_type(type:, dir:, range: nil)
      when_type(type)
        .reverse_each do |seg|
          next if range && not_in_range?(seg, range)

          if is_first_seg?(seg)
            collapse_first_token if type == :comma
          elsif is_last_seg?(seg)
            collapse_last_token if type == :comma
          else
            collapse_segment(seg, dir)
          end
        end
      self
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
      replace_segments_with_new(segs: sources, new: new)
    end

    # Derives a single token from the first and second tokens in the
    # result, keeping the second token's type
    def collapse_first_token
      collapse_token_pair_forward(segments[0], segments[1])
    end

    # Derives a single token from the last and next-to-last tokens in the
    # result, keeping the next-to-last token's type
    def collapse_last_token
      collapse_token_pair_backward(segments[-2], segments[-1])
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
      segs = extract(old)
      newsegment = Emendate::Segment.new(type: new, sources: segs)
      insert(ins_pt(segs[0]), newsegment)
      segs.each { |segment| delete(segment) }
    end

    # @param segs [Array<Emendate::Segment>]
    # @param date_part_type [Symbol]
    def replace_segs_with_new_type(segs:, type:)
      new = Emendate::Segment.new(type: type, sources: segs)
      insert(ins_pt(segs[0]), new)
      segs.each { |x| delete(x) }
    end

    # @param segs [Array<Emendate::Segment>] to replace
    # @param new [Emendate::Segment] replacement
    def replace_segments_with_new(segs:, new:)
      insert(ins_pt(segs[-1]), new)
      segs.each { |segment| delete(segment) }
    end

    # @param segs [Array<Emendate::Segment>] to replace
    # @param new [Emendate::SegmentSet] replacement
    def replace_segments_with_new_segment_set(segs:, new:)
      insert(ins_pt(segs[-1]), *new.segments)
      segs.each { |segment| delete(segment) }
      new.warnings.each { |warn| add_warning(warn) }
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
      insert(ins_pt(x), new)
      delete(x)
    end

    # @param x [Emendate::Segment]
    # @param date_part_type [Symbol]
    def replace_x_with_date_part_type(x:, date_part_type:)
      replace_segs_with_new_type(segs: [x], type: date_part_type)
    end

    # @param seg [Emendate::Segment]
    # @param newseg [Emendate::Segment]
    def insert_segment_after_segment(seg, newseg)
      insert(ins_pt(seg), newseg)
    end

    # @param seg [Emendate::Segment]
    # @param newseg [Emendate::Segment]
    def insert_segment_before_segment(seg, newseg)
      insert(ins_pt(seg, :prev), newseg)
    end

    # @param seg [Emendate::Segment]
    # @param dummytype [Symbol]
    def insert_dummy_after_segment(seg, dummytype)
      newsegment = Emendate::Segment.new(type: dummytype)
      insert_segment_after_segment(seg, newsegment)
    end

    private

    # @param seg [Emendate::Segment]
    # @param dir [:forward, :backward]
    # @return [Emendate::Segment]
    def target_by_direction(seg, dir)
      targetind = (dir == :forward) ? 1 : -1
      segments[index_of(seg) + targetind]
    end
  end
end
