# frozen_string_literal: true

module Emendate
  module DateTypes
    # @abstract Subclasses implement specific usable date types.
    class DateType
      attr_reader :certainty, :range_switch, :location
      attr_accessor :partial_indicator, :sources

      # @option opts [SegmentSets::SegmentSet, Array<Segment>] :sources (nil)
      # @option opts [:early, :mid, :late] :partial_indicator (nil) Changes the
      #   function of `earliest` and `latest` to reflect only part of the
      #   overall date part
      # @option opts [:before, :after] :range_switch (nil) Forces
      #   `earliest`/`latest` to reflect the range before or after this
      #   particular date
      # @option opts [Array<Symbol>] :certainty (nil) Individual
      #   date-type-specific certainty values (i.e. day approximate)
      #   as opposed to the certainty attribute on the SegmentSet for
      #   the entire date value
      # @option opts [Emendate::Location] :location (nil)
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
        @location = sources ? sources.location : opts[:location]
      end

      # @param value [Symbol, String] the range switch to add to date type
      def add_range_switch(value)
        @range_switch = value.to_sym
      end

      # @param token [{Segment}] or subclasses of {Segment}
      def prepend_source_token(token)
        @sources.unshift(token)
        self
      end

      # @return [TrueClass]
      # All DateType segments are date parts. Supports expected behavior as
      # member of a {SegmentSets::SegmentSet}
      def date_part?
        true
      end

      # @return [TrueClass]
      # Supports expected behavior as member of a {SegmentSets::SegmentSet}
      def date_type?
        true
      end

      # @return [TrueClass]
      # @todo What is this? Is it still needed? If so, document.
      def processed?
        true
      end

      # @abstract Implement in subclasses.
      # @raise [NotImplementedError]
      def earliest
        raise NotImplementedError,
              "#{self.class} has not implemented method '#{__method__}'"
      end

      # @abstract Implement in subclasses.
      # @raise [NotImplementedError]
      def latest
        raise NotImplementedError,
              "#{self.class} has not implemented method '#{__method__}'"
      end

      # @abstract Override in date types with non-year level of granularity
      # @return [String] representation of earliest year
      def earliest_at_granularity
        earliest.year
      end

      # @abstract Override in date types with non-year level of granularity
      # @return [String] representation of latest year
      def latest_at_granularity
        latest.year
      end

      # @abstract Implement in subclasses.
      # @raise [NotImplementedError]
      def lexeme
        raise NotImplementedError,
              "#{self.class} has not implemented method '#{__method__}'"
      end

      # @abstract Implement in subclasses.
      # @raise [NotImplementedError]
      def range?
        raise NotImplementedError,
              "#{self.class} has not implemented method '#{__method__}'"
      end

      # Makes DateTypes behave as good members of a {SegmentSets::SegmentSet}
      # @return [Symbol]
      def type
        "#{self.class.name.split('::').last.downcase}_date_type".to_sym
      end
    end
  end
end
