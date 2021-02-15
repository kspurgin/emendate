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
      attr_reader :type, :certainty
      attr_accessor :partial_indicator, :range_switch, :source_tokens
      def initialize(**opts)
        @source_tokens = opts[:children].nil? ? [] : Emendate::MixedSet.new(opts[:children])
        @partial_indicator = opts[:partial_indicator]
        @range_switch = opts[:range_switch]
        @certainty = opts[:certainty].nil? ? [] : opts[:certainty]
      end

      def date_part?
        true
      end

      def earliest
        raise NotImplementedError
      end

      def latest
        raise NotImplementedError
      end

      def lexeme
        raise NotImplementedError
      end
      
      def range?
        raise NotImplementedError
      end
      
      def type
        "#{self.class.name.split('::').last.downcase}_date_type".to_sym
      end
    end
  end
end
