# frozen_string_literal: true

module Emendate
  # Methods used by processing step Objects to edit the result they return
  # This is not the final result
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

    # @param s1 [{Segment}] first of pair
    # @param s2 [{Segment}] second of pair
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

    # @todo do we need to set lexeme and literal like this?
    def new_date_part(type, sources)
      Emendate::Segment.new(type: type,
        lexeme: sources.map(&:lexeme).join,
        literal: sources[0].literal,
        sources: sources)
    end

    # @param segment_types [Array<Symbol>] of segments to replace
    # @param type [Symbol] for new derived replacement
    def replace_segments_with_derived_new_type(segment_types:, type:)
      segments = result.extract(segment_types)
      ins_pt = result.find_index(segments[-1]) + 1
      newsegment = Emendate::Segment.new(type: type, sources: segments)
      result.insert(ins_pt, newsegment)
      segments.each { |segment| result.delete(segment) }
    end

    # Given an array of segments and a new (derived) segment, replaces
    # the former with the latter
    def replace_segments_with_new(segments:, new:)
      ins_pt = result.find_index(segments[-1]) + 1
      result.insert(ins_pt, new)
      segments.each { |segment| result.delete(segment) }
    end

    # @param x [Segment] to replace
    # @param type [Symbol] type of the new segment
    def replace_x_with_derived_new_type(x:, type:)
      ins_pt = result.find_index(x) + 1
      newsegment = Emendate::Segment.new(type: type, sources: [x])
      result.insert(ins_pt, newsegment)
      result.delete(x)
    end

    def replace_x_with_new(x:, new:)
      ins_pt = result.find_index(x) + 1
      result.insert(ins_pt, new)
      result.delete(x)
    end

    def replace_multi_with_date_part_type(sources:, date_part_type:)
      new_date_part = new_date_part(date_part_type, sources)
      x_ind = result.find_index(sources[0])
      result.insert(x_ind + 1, new_date_part)
      sources.each { |x| result.delete(x) }
    end

    def replace_x_with_date_part_type(x:, date_part_type:)
      new_date_part = new_date_part(date_part_type, [x])
      #      binding.pry
      x_ind = result.find_index(x)
      result.insert(x_ind + 1, new_date_part)
      result.delete(x)
    end

    def replace_x_with_given_segment(x:, segment:)
      x_ind = result.find_index(x)
      result.insert(x_ind + 1, segment)
      result.delete(x)
    end
  end
end
