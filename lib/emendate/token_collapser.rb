# frozen_string_literal: true

require "emendate/date_utils"

module Emendate
  class TokenCollapser
    include Dry::Monads[:result]

    class << self
      def call(...)
        new(...).call
      end
    end

    DATE_SEPARATORS = %i[hyphen slash]

    def initialize(tokens)
      @result = Emendate::SegmentSet.new.copy(tokens)
    end

    def call
      while collapsible?
        action = determine_action
        break if action.nil?

        pre = result.types.dup
        action.call
        break if result.types == pre
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
        proc { collapse_segment(result[0], :forward) }
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
      when /.*number4 (hyphen|slash) number1or2 \1 number1or2.*/
        proc do
          remove_date_separators_in_subset(%i[number4 number1or2 number1or2])
        end
      when /.*month number1or2 comma number4.*/
        proc do
          segs = result.extract(
            %i[month number1or2 comma number4]
          ).segments
          result.collapse_segment(segs[2], :backward)
        end
      when /.*number4 comma month number1or2.*/
        proc do
          segs = result.extract(%i[number4 comma month number1or2]).segments
          result.collapse_segment(segs[1], :backward)
        end
      when /.*apostrophe letter_s.*/
        proc { result.collapse_segments_forward(%i[apostrophe letter_s]) }
      when /.*apostrophe number1or2.*/
        proc { result.collapse_segments_forward(%i[apostrophe number1or2]) }
      when /.*before hyphen.*/
        proc { result.collapse_segments_backward(%i[before hyphen]) }
      when /.*partial hyphen.*/
        proc { result.collapse_segments_backward(%i[partial hyphen]) }
      when /.*parenthesis_open [^ ]+ parenthesis_close.*/
        proc { collapse_single_element_parenthetical }
      when /.*hyphen unknown_date.*/
        proc do
          segs = result.extract(%i[hyphen unknown_date])
          result.replace_x_with_derived_new_type(
            x: segs[0], type: :range_indicator
          )
        end
      when /.*unknown_date hyphen.*/
        proc do
          segs = result.extract(%i[unknown_date hyphen])
          result.replace_x_with_derived_new_type(
            x: segs[1], type: :range_indicator
          )
        end
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

          result.collapse_all_matching_type(type: type, dir: :backward)
        end
      end
    end

    def collapse_backward
      to_collapse = result.segments.reverse.find(&:collapsible?)
      result.collapse_segment(to_collapse, :backward)
    end

    def remove_date_separators_in_subset(pattern)
      range = DATE_SEPARATORS.map do |sep|
        result.range_matching_separated_pattern(pattern, sep)
      end.compact
        .first
      return unless range

      result.collapse_all_matching_type(
        type: result[range.first + 1].type,
        dir: :backward,
        range: range
      )
    end

    def collapse_single_element_parenthetical
      matches = result.type_string
        .match(/.*(parenthesis_open ([^ ]+) parenthesis_close).*/)
      result.replace_segtypes_with_new_type(
        old: matches[1].split(" ").map(&:to_sym),
        new: matches[2].to_sym
      )
    end
  end
end
