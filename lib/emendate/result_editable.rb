# frozen_string_literal: true

module Emendate
  # Methods used by processing step Objects to edit the result they return
  # This is not the final result
  # Classes including this module must have a `result` attr_reader
  module ResultEditable
    # derives a single token from 2 or more tokens, keeping the first token's type
    # @param ary [Array<Symbol>]
    def collapse_segments_backward(ary)
      segments = result.extract(ary).segments
      target = segments.first
      collapsed = segments[1..-1]
      derived = Emendate::DerivedToken.new(type: target.type, sources: collapsed)
      replace_segments_with_new(segments: segments, new: derived)
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
  end
end
