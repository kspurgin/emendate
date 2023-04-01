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
      attr_accessor :partial_indicator, :range_switch, :sources

      def initialize(**opts)
        srcs = opts[:sources]
        @sources = if srcs.nil?
                     Emendate::SegmentSets::MixedSet.new
                   elsif srcs.is_a?(Emendate::SegmentSets::SegmentSet)
                     srcs.class.new.copy(srcs)
                   else
                     Emendate::SegmentSets::MixedSet.new(
                       segments: srcs
                     )
                   end
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

      def processed?
        true
      end

      def earliest
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def latest
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      # most date types will have year granularity. Override this in datetypes that do not
      def earliest_at_granularity
        earliest.year
      end

      # most date types will have year granularity. Override this in datetypes that do not
      def latest_at_granularity
        latest.year
      end

      def lexeme
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def location
        @sources.location
      end

      def prepend_source_token(token)
        @sources.unshift(token)
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
