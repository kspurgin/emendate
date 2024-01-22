# frozen_string_literal: true

require "emendate/date_utils"
require "emendate/result_editable"

module Emendate
  class TokenCollapser
    include Dry::Monads[:result]
    include ResultEditable

    class << self
      def call(...)
        new(...).call
      end
    end

    DATE_SEPARATORS = %i[hypen slash]

    def initialize(tokens)
      @result = Emendate::SegmentSets::SegmentSet.new.copy(tokens)
    end

    def call
      while collapsible?
        action = determine_action
        break if action.nil?

        action.call
      end
      full_match_date_part_collapsers
      Success(result)
    end

    private

    attr_reader :result

    def collapsible?
      return true if full_match_collapsers || partial_match_collapsers

      result.any?(&:collapsible?)
    end

    def determine_action
      actions = if result[0].collapsible?
        proc { collapse_forward }
      elsif result.any?(&:collapsible?)
        proc { collapse_backward }
      end
      return actions unless actions.nil?

      actions = full_match_collapsers
      return actions unless actions.nil?

      partial_match_collapsers
    end

    def full_match_collapsers
      # case result.types
      # when %i[number1or2 slash number4]
      #   proc { collapse_segments_backward(%i[number1or2 slash]) }
      # end
    end

    def partial_match_collapsers
      case result.type_string
      when /.*number1or2 (hyphen|slash) number1or2 \1 number4.*/
        proc do
          remove_date_separators_in_subset(%i[number1or2 number1or2 number4])
        end
      when /.*month number1or2 comma number4.*/
        proc do
          segs = result.extract(
            %i[month number1or2 comma number4]
          ).segments
          collapse_segment(segs[2], :backward)
        end
      when /.*number4 comma month number1or2.*/
        proc do
          segs = result.extract(%i[number4 comma month number1or2]).segments
          collapse_segment(segs[1], :backward)
        end
      when /.*apostrophe letter_s.*/
        proc { collapse_segments_forward(%i[apostrophe letter_s]) }
      when /.*apostrophe number1or2.*/
        proc { collapse_segments_forward(%i[apostrophe number1or2]) }
      when /.*before hyphen.*/
        proc { collapse_segments_backward(%i[before hyphen]) }
      when /.*partial hyphen.*/
        proc { collapse_segments_backward(%i[partial hyphen]) }
      when /.*parenthesis_open [^ ]+ parenthesis_close.*/
        proc { collapse_single_element_parenthetical }
      end
    end

    def full_match_date_part_collapsers
      dateparts = result.date_part_types.sort.join(" ")

      matchers = [
        /^month number4$/,
        /^month number1or2 number4$/,
        /^number1or2 number1or2 number1or2$/,
        /^number1or2 number1or2 number4$/,
        /^number1or2 number4$/,
        /^number1or2 season$/,
        /^number4 season$/
      ]

      if matchers.any? { |matcher| matcher.match(dateparts) }
        types = result.types.uniq
        %i[comma hyphen slash].each do |type|
          next unless types.include?(type)

          collapse_all_matching_type(type: type, dir: :backward)
        end
      end
    end

    def collapse_backward
      to_collapse = result.segments.reverse.find(&:collapsible?)
      prev = result[result.find_index(to_collapse) - 1]
      collapse_token_pair_backward(prev, to_collapse)
    end

    def collapse_forward
      collapse_token_pair_forward(result[0], result[1])
    end

    def remove_date_separators_in_subset(pattern)
      segs = DATE_SEPARATORS.map do |sep|
        extract_pattern_separated_by(pattern, sep)
      end.compact
        .first
      return unless segs

      insertion = ins_pt(segs[0], :prev)

      cleaned = collapse_all_matching_type(
        type: segs[1].type,
        dir: :backward
      )
    end

    def collapse_single_element_parenthetical
      matches = result.type_string
        .match(/.*(parenthesis_open ([^ ]+) parenthesis_close).*/)
      replace_segtypes_with_new_type(
        old: matches[1].split(" ").map(&:to_sym),
        new: matches[2].to_sym
      )
    end
  end
end
