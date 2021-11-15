# frozen_string_literal: true

require 'emendate/date_utils'
require 'emendate/result_editable'

module Emendate
  class TokenCollapser
    include ResultEditable
    attr_reader :result, :options

    def initialize(tokens:, options: {})
      @result = Emendate::TokenSet.new.copy(tokens)
      @options = options
    end

    def collapse
      while collapsible?
        action = determine_action
        break if action.nil?

        send(action)
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
      result.type_string.match?(/space|single_dot|standalone_zero/)
    end

    def determine_action
      if result[0].collapsible?
        :collapse_forward
      else
        :collapse_backward
      end
    end
  end
end
