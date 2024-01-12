# frozen_string_literal: true

require 'emendate/date_utils'
require 'emendate/result_editable'

module Emendate
  class TokenCollapser
    include Dry::Monads[:result]
    include ResultEditable

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = Emendate::SegmentSets::TokenSet.new.copy(tokens)
    end

    def call
      while collapsible?
        action = determine_action
        break if action.nil?

        action.call
      end
      Success(result)
    end

    private

    attr_reader :result

    def collapsible?
      return true if full_match_collapsers || partial_match_collapsers

      result.any?(&:collapsible?)
    end

    def determine_action
      actions = full_match_collapsers
      return actions unless actions.nil?

      actions = partial_match_collapsers
      return actions unless actions.nil?

      if result[0].collapsible?
        proc{ collapse_forward }
      else
        proc{ collapse_backward }
      end
    end

    def full_match_collapsers
      case result.types
      when %i[number1or2 slash number4]
        proc{ collapse_segments_backward(%i[number1or2 slash]) }
      when %i[month_alpha comma space number4]
        proc{ collapse_segments_backward(%i[month_alpha comma]) }
      when %i[month_alpha comma space number1or2 comma space number4]
        proc do
          collapse_segments_backward(%i[number1or2 comma])
          collapse_segments_backward(%i[month_alpha comma])
        end
      end
    end

    def partial_match_collapsers
      case result.type_string
      when /.*apostrophe letter_s.*/
        proc{ collapse_segments_forward(%i[apostrophe letter_s]) }
      when /.*apostrophe number1or2.*/
        proc{ collapse_segments_forward(%i[apostrophe number1or2]) }
      when /.*before hyphen.*/
        proc{ collapse_segments_backward(%i[before hyphen]) }
      when /.*partial hyphen.*/
        proc{ collapse_segments_backward(%i[partial hyphen]) }
      when /.*month_abbr_alpha single_dot space.*/
        proc {
          collapse_segments_backward(
            %i[month_abbr_alpha single_dot space]
          )
        }
      when /.*parenthesis_open [^ ]+ parenthesis_close.*/
        proc{ collapse_single_element_parenthetical }
      end
    end

    def collapse_backward
      to_collapse = result.segments.select(&:collapsible?).last
      prev = result[result.find_index(to_collapse) - 1]
      collapse_token_pair_backward(prev, to_collapse)
    end

    def collapse_forward
      collapse_token_pair_forward(result[0], result[1])
    end

    def collapse_single_element_parenthetical
      matches = result.type_string
                      .match(/.*(parenthesis_open ([^ ]+) parenthesis_close).*/)
      replace_segments_with_derived_new_type(
        segment_types: matches[1].split(' ').map(&:to_sym),
        type: matches[2].to_sym
      )
    end
  end
end
