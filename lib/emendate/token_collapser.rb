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

        action.is_a?(Symbol) ? send(action) : send(action.shift, action)
      end
      result
    end

    private

    def collapse_backward
      to_collapse = result.segments.select(&:collapsible?).last
      prev = result[result.find_index(to_collapse) - 1]
      collapse_token_pair_backward(prev, to_collapse)
    end
    
    def collapse_forward
      collapse_token_pair_forward(result[0], result[1])
    end
    
    def collapsible?
      return true if full_match_collapsers || partial_match_collapsers

      result.type_string.match?(/space|single_dot|standalone_zero/)
    end

    def determine_action
      actions = full_match_collapsers
      return actions unless actions.nil?

      actions = partial_match_collapsers
      return actions unless actions.nil?
      
      if result[0].collapsible?
        :collapse_forward
      else
        :collapse_backward
      end
    end

    def full_match_collapsers
      case result.types
      when %i[number1or2 slash number4]
        [:collapse_segments_backward, :number1or2, :slash]
      end
    end
    
    def partial_match_collapsers
      case result.type_string
      when /.*before hyphen.*/
        %i[collapse_segments_backward before hyphen]
      when /.*partial hyphen.*/
        %i[collapse_segments_backward partial hyphen]
      when /.*month_abbr_alpha single_dot space.*/
        %i[collapse_segments_backward month_abbr_alpha single_dot space]
      end
    end
  end
end
