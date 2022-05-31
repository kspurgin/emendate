# frozen_string_literal: true

require 'emendate/date_utils'
require 'emendate/result_editable'

module Emendate
  class TokenCollapser
    include ResultEditable
    attr_reader :result, :options

    def initialize(tokens:, options: {})
      @result = Emendate::SegmentSets::TokenSet.new.copy(tokens)
      @options = options
    end

    def collapse
      while collapsible?
        action = determine_action
        break if action.nil?

        action.is_a?(Symbol) ? send(action) : send(action[0], action[1])
      end
      result
    end

    private

    def collapse_abbrev_month
      month, dot, space = result.extract(%i[month_abbr_alpha single_dot space]).segments
      derived = Emendate::DerivedToken.new(type: month.type, sources:[month, dot, space])
      replace_segments_with_new(segments: [month, dot, space], new: derived)
    end

    def collapse_backward
      to_collapse = result.segments.select(&:collapsible?).last
      prev = result[result.find_index(to_collapse) - 1]
      collapse_token_pair_backward(prev, to_collapse)
    end
    
    def collapse_forward
      collapse_token_pair_forward(result[0], result[1])
    end

    def collapse_hyphen_backward(previous)
      prev, hyp = result.extract([previous, :hyphen]).segments
      derived = Emendate::DerivedToken.new(type: prev.type, sources:[prev, hyp])
      replace_segments_with_new(segments: [prev, hyp], new: derived)
    end
    
    def collapsible?
      return true if partial_match_collapsers

      result.type_string.match?(/space|single_dot|standalone_zero/)
    end

    def determine_action
      actions = partial_match_collapsers
      return actions unless actions.nil?
      
      if result[0].collapsible?
        :collapse_forward
      else
        :collapse_backward
      end
    end

    def partial_match_collapsers
      case result.type_string
      when /.*before hyphen.*/
        [:collapse_hyphen_backward, :before]
      when /.*partial hyphen.*/
        [:collapse_hyphen_backward, :partial]
      when /.*month_abbr_alpha single_dot space.*/
        :collapse_abbrev_month
      end
    end
  end
end
