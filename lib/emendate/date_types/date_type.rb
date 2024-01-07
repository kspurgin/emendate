# frozen_string_literal: true

module Emendate
  module DateTypes
    # @abstract Subclasses implement specific usable date types.
    class DateType
      # @return [SegmentSets::SegmentSet]
      attr_reader :sources

      # @return [Array<Symbol>]
      attr_reader :certainty

      # @return [Symbol]
      attr_reader :partial_indicator

      # @return [Symbol]
      attr_reader :range_switch

      # @param sources [SegmentSets::SegmentSet, Array<Segment>] Segments
      #   included in the date type
      # @param certainty [Array<Symbol>] Individual date-type-specific
      #   certainty values (i.e. day approximate) as opposed to the
      #   certainty attribute on the SegmentSet for the entire date
      #   value
      # @param partial_indicator [:early, :mid, :late] Changes the
      #   function of `earliest` and `latest` to reflect only part of the
      #   overall date part
      # @param range_switch [:before, :after] Forces
      #   `earliest`/`latest` to reflect the range before or after
      #   this particular date
      def initialize(sources:, certainty: nil, partial_indicator: nil,
                     range_switch: nil)
        @sources = set_sources(sources)
        @partial_indicator = partial_indicator
        @range_switch = :range_switch
        @certainty = certainty || []
      end

      # Allows addition/changing of a range switch after date type has been
      # created
      # @param value [Symbol, String] the range switch to add to date type
      def add_range_switch(value)
        @range_switch = value.to_sym
      end

      # Allows a source to be added to beginning of sources after date type has
      # been created
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
      # Supports ProcessingManager's checking for unprocessed segments while
      # finalizing result
      def processed?
        true
      end

      # Makes DateTypes behave as good members of a {SegmentSets::SegmentSet}
      # @return [Symbol]
      def type
        "#{self.class.name.split('::').last.downcase}_date_type".to_sym
      end

      # @return [String]
      def lexeme
        sources.empty? ? '' : sources.lexeme
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

      # @abstract Implement in subclasses.
      # @raise [NotImplementedError]
      def range?
        raise NotImplementedError,
              "#{self.class} has not implemented method '#{__method__}'"
      end

      private

      def set_sources(sources)
        if sources.nil?
          Emendate::SegmentSets::MixedSet.new
        elsif sources.is_a?(Emendate::SegmentSets::SegmentSet)
          srcs.class.new.copy(sources)
        else
          Emendate::SegmentSets::MixedSet.new(
            segments: sources
          )
        end
      end
    end
  end
end
