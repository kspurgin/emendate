# frozen_string_literal: true

module Emendate
  module DateTypes
    # Mixin module for DateType classes
    #
    # *Implementation detail*
    #
    # Classes including this module should define the following instance
    #   methods:
    #
    # * earliest (Date)
    # * latest (Date)
    # * range? (Boolean)
    module Datetypeable
      # @return [Array<Symbol>]
      attr_reader :certainty
      # @return [SegmentSets::SegmentSet]
      attr_reader :sources

      # Allows a source segment to be added to beginning of sources
      # after date type has been created
      # @param token [{Segment}] or subclasses of {Segment}
      def prepend_source_token(token)
        unless addable_token_types.include?(token.type)
          raise Emendate::DisallowedTokenAdditionError.new(
            token, __method__, self.class
          )
        end

        @sources.unshift(token)
        # @todo Check if this actually needs to return self
        self
      end

      # Allows a source segment to be added to end of sources after
      # date type has been created
      # @param token [{Segment}] or subclasses of {Segment}
      def append_source_token(token)
        unless addable_token_types.include?(token.type)
          raise Emendate::DisallowedTokenAdditionError.new(
            token, __method__, self.class
          )
        end

        @sources << token
        # @todo Check if this actually needs to return self
        self
      end

      # Allows addition/changing of a range switch after date type has been
      # created
      # @param value [Symbol, String] the range switch to add to date type
      def add_range_switch(value)
        @range_switch = value.to_sym
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

      # Override in date types with non-year level of granularity
      # @return [String] representation of earliest year
      def earliest_at_granularity
        earliest.year
      end

      # Override in date types with non-year level of granularity
      # @return [String] representation of latest year
      def latest_at_granularity
        latest.year
      end

      # @param type [Symbol] Segment type
      # @return [Boolean] Whether or not it is an addable source type
      def addable?(type) = addable_token_types.include?(type)

      # @return [NilClass] if Date Type does not allow append/prepend of
      #   :era_bce type
      # @return [:bce] if source types include :era_bce
      # @return [:ce] otherwise
      def era
        return unless addable_token_types.include?(:era_bce)
        return :bce if sources.types.include?(:era_bce)

        :ce
      end

      # @return [:early, :mid, :late, nil]
      def partial_indicator
        return nil unless sources.types.include?(:partial)

        sources.when_type(:partial).first.literal
      end

      # @return [:before, :after, nil]
      def range_switch
        chk = [
          sources.when_type(:before).first,
          sources.when_type(:after).first
        ].compact
        return nil if chk.empty?

        chk.first.type
      end

      private

      def set_sources(context)
        srcs = context.local_variable_get(:sources)
        @sources = if srcs.nil?
                     Emendate::SegmentSets::MixedSet.new
                   elsif srcs.is_a?(Emendate::SegmentSets::SegmentSet)
                     srcs.class.new.copy(srcs)
                   else
                     Emendate::SegmentSets::MixedSet.new(
                       segments: srcs
                     )
                   end
      end

      def common_setup(context)
        set_sources(context)
        instance_variable_set(:@certainty, [])
      end

      def first_numeric_literal
        sources.map(&:literal)
               .select{ |literal| literal.is_a?(Integer) }
               .first
      end

      # Override in any including class that shouldn't allow append/prepend of
      #   any of these default token types, or that needs to allow
      #   append/prepend of additional types
      def addable_token_types = %i[partial before after]
    end
  end
end
