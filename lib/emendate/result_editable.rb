# frozen_string_literal: true

module Emendate
  # Methods used by processing step Objects to edit the result they return
  # This is not the final result
  # Classes including this module must have a `result` attr_reader
  module ResultEditable
    # derives a single token from 2 or more tokens, keeping the first token's type
    # @param ary [Array<Symbol>]
    def collapse_segments_backward(ary)
      segs = result.extract(ary).segments
      derived = Emendate::DerivedToken.new(type: segs.first.type, sources: segs)
      replace_segments_with_new(segments: segs, new: derived)
    end

    # derives a single token from 2 or more tokens, keeping the final token's type
    # @param ary [Array<Symbol>]
    def collapse_segments_forward(ary)
      segs = result.extract(ary).segments
      derived = Emendate::DerivedToken.new(type: segs.last.type, sources: segs)
      replace_segments_with_new(segments: segs, new: derived)
    end

    # derives a single token from two tokens, keeping the first token's type
    def collapse_token_pair_backward(s1, s2)
      new = Emendate::DerivedToken.new(type: s1.type, sources: [s1, s2])
      replace_segments_with_new(segments: [s1, s2], new: new)
    end

    # derives a single token from two tokens, keeping the second token's type
    def collapse_token_pair_forward(s1, s2)
      new = Emendate::DerivedToken.new(type: s2.type, sources: [s1, s2])
      replace_segments_with_new(segments: [s1, s2], new: new)
    end

    # @param x Emendate::Segment (or subclass)
    def move_x_to_end(x)
      result.delete(x)
      result << x
    end

    def new_date_part(type, sources)
      Emendate::DatePart.new(type: type,
                             lexeme: sources.map(&:lexeme).join,
                             literal: sources[0].literal,
                             source_tokens: sources)
    end

    # given an array of segments and a new (derived) segment, replaces the former with the latter
    def replace_segments_with_new(segments:, new:)
      ins_pt = result.find_index(segments[-1]) + 1
      result.insert(ins_pt, new)
      segments.each{ |segment| result.delete(segment) }
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
      sources.each{ |x| result.delete(x) }
    end

    def replace_x_with_date_part_type(x:, date_part_type:)
      new_date_part = new_date_part(date_part_type, [x])
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
