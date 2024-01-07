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
      # @return [:early, :mid, :late, nil]
      attr_reader :partial_indicator
      # @return [:before, :after, nil]
      attr_reader :range_switch

      # Allows a source segment to be added to beginning of sources
      # after date type has been created
      # @param token [{Segment}] or subclasses of {Segment}
      def prepend_source_token(token)
        @sources.unshift(token)
        self
      end

      # Allows a source segment to be added to end of sources after
      # date type has been created
      # @param token [{Segment}] or subclasses of {Segment}
      def append_source_token(token)
        @sources << token
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
        vars = context.local_variables - [:sources]
        %i[certainty partial_indicator range_switch].each do |var|
          iv = "@#{var}".to_sym
          if vars.include?(var)
            instance_variable_set(iv, context.local_variable_get(var))
          else
            case var
            when :certainty
              # passthrough for now
            when :partial_indicator
              instance_variable_set(
                :@partial_indicator, partial_indicator_value
              )
            when :range_switch
              instance_variable_set(
                :@range_switch, range_switch_value
              )
            end
          end
        end
      end

      def partial_indicator_value
        return nil unless sources.types.include?(:partial)

        sources.when_type(:partial).first.literal
      end

      def range_switch_value
        chk = [
          sources.when_type(:before).first,
          sources.when_type(:after).first
        ].compact
        return nil if chk.empty?

        chk.first.type
      end

      def first_numeric_literal
        sources.map(&:literal)
               .select{ |literal| literal.is_a?(Integer) }
               .first
      end
    end
  end
end
