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
        @source_tokens = opts[:children].nil? ? [] : Emendate::MixedSet.new(opts[:children])
        @partial_indicator = opts[:partial_indicator]
        @range_switch = opts[:range_switch]
        @certainty = opts[:certainty].nil? ? [] : opts[:certainty]
      end

      def date_part?
        true
      end

      def date_type?
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

      def parsed(whole_certainty:)
        h = {}
        h[:index_dates] = nil
        h[:date_start] = nil
        h[:date_end] = nil
        h[:date_start_full] = earliest.nil? ? nil : earliest.iso8601
        h[:date_end_full] = latest.nil? ? nil : latest.iso8601
        h[:inclusive_range] = range? ? true : nil
        h[:certainty] = whole_certainty
        certainty.each{ |c| h[:certainty] << c }
        h[:certainty].uniq!
        h
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
