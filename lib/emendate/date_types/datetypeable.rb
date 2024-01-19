# frozen_string_literal: true

require_relative "../qualifiable"

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
      # @return [Array<Emendate::Qualifier>]
      attr_reader :qualifiers

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

      # Allows a qualifier to be added to end of qualifiers after
      # date type has been created
      # @param qual [Emendate::Qualifier]
      def add_qualifier(qual)
        @qualifiers << qual
      end

      # @return [TrueClass]
      # All DateType segments are date parts. Supports expected behavior as
      # member of a {SegmentSets::SegmentSet}
      def date_part? = true

      # @return [TrueClass]
      # Supports expected behavior as member of a {SegmentSets::SegmentSet}
      def date_type? = true

      # @return [TrueClass]
      # Supports ProcessingManager's checking for unprocessed segments while
      # finalizing result
      def processed?
        true
      end

      # Makes DateTypes behave as good members of a {SegmentSets::SegmentSet}
      # @return [Symbol]
      def type
        :"#{self.class.name.split("::").last.downcase}_date_type"
      end

      # @return [String]
      def lexeme
        sources.empty? ? "" : sources.lexeme
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

      def orig_string = sources.first.orig_string

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

      # Override to true and define `:process_qualifiers` method in including
      # classes that are qualifiable dates (e.g. with approximate and/or
      # uncertain qualifiers)
      # @return [FalseClass]
      def qualifiable? = false

      # Override to true and define `:validate` method in including classes
      #   that should verify assumptions about sources on initialization.
      # @return [FalseClass]
      def validatable? = false

      private

      def set_sources(context)
        srcs = context.local_variable_get(:sources)
        @sources = if srcs.nil?
          Emendate::SegmentSets::SegmentSet.new
        elsif srcs.is_a?(Emendate::SegmentSets::SegmentSet)
          srcs.class.new.copy(srcs)
        else
          Emendate::SegmentSets::SegmentSet.new(
            segments: srcs
          )
        end
      end

      def common_setup(context)
        set_sources(context)
        instance_variable_set(:@certainty, [])
        instance_variable_set(:@qualifiers, [])
        validate if validatable?
        if qualifiable?
          self.class.include Emendate::Qualifiable
          process_qualifiers
        end
      end

      def first_numeric_literal
        sources.map(&:literal)
          .find { |literal| literal.is_a?(Integer) }
      end

      # Override in any including class that shouldn't allow append/prepend of
      #   any of these default token types, or that needs to allow
      #   append/prepend of additional types
      def addable_token_types = %i[partial before after]

      def validate
        raise Emendate::DateTypeCreationError, "#{self.class}: implement "\
          "`:validate` method or remove override of `:validatable?` to true"
      end

      def has_x_date_parts(num)
        parts = sources.date_part_types
        unless parts.length == num
          raise Emendate::DateTypeCreationError, "#{self.class}: Expected "\
            "creation with #{num} date_parts. Received #{parts.length}: "\
            "#{parts.join(", ")}"
        end
      end

      def process_qualifiers
        raise Emendate::DateTypeCreationError, "#{self.class}: implement "\
          "`:process_qualifiers` method or remove override of `:qualifiable?` "\
          "to true"
      end

      def has_one_part_of_type(type)
        segs = sources.select { |seg| seg.type == type }
        unless segs.length == 1
          raise Emendate::DateTypeCreationError, "#{self.class}: Expected "\
            "one #{type} date part. Found #{segs.length}"
        end
      end
    end
  end
end
