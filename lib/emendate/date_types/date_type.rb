# frozen_string_literal: true

module Emendate
  module DateTypes

    # DateType implements type so that it behaves as a good member of a SegmentSet
    # certainty contains any individual date-specific certainty values (i.e. day approximate) as opposed to the
    #   certainty attribute on the SegmentSet for the entire date value
    # partial_indicator (early, mid, late) changes the function of `earliest` and `latest` to reflect
    #   only part of the overall date part
    # range_switch (before, after) forces `earliest`/`latest` to reflect the range before or after this
    #   particular date
    class DateType
      attr_reader :certainty
      attr_accessor :partial_indicator, :range_switch, :source_tokens

      def initialize(**opts)
        @source_tokens = opts[:children].nil? ? Emendate::SegmentSets::MixedSet.new : Emendate::SegmentSets::MixedSet.new(opts[:children])
        @partial_indicator = opts[:partial_indicator]
        @range_switch = opts[:range_switch]
        @certainty = opts[:certainty].nil? ? [] : opts[:certainty]
        @location = location
      end
      
      def date_part?
        true
      end

      def date_type?
        true
      end

      def earliest
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def latest
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def earliest_at_granularity
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def latest_at_granularity
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def lexeme
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def location
        @source_tokens.location
      end

      def prepend_source_token(token)
        @source_tokens.unshift(token)
        self
      end
            
      def range?
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def type
        "#{self.class.name.split('::').last.downcase}_date_type".to_sym
      end
    end
  end
end
