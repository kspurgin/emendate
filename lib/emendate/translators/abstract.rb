# frozen_string_literal: true

module Emendate
  module Translators
    # Abstract class defining the interface common to all translators
    #
    class Abstract
      # @param processed [Emendate::ProcessingManager]
      # @param pdate [Emendate::ParsedDate]
      def translate(processed, pdate)
        @processed = processed
        @pdate = pdate
        @warnings = processed.warnings.flatten.uniq
        @base = nil
        @qualified = nil
        preprocess if respond_to?(:preprocess)

        translate_value
        TranslatedDate.new(
          orig: processed.orig_string,
          value: qualified || base,
          warnings: warnings
        )
      end

      private

      attr_reader :processed, :pdate, :value, :warnings
      # @return [String, Hash] the processed value before any qualification
      attr_reader :base
      # @return [String, Hash] qualified processed value
      attr_reader :qualified

      def qualify
        @qualified = base.dup
        qualify_qualifiers
        qualify_set
        qualified
      end

      def qualify_qualifiers
        return if pdate.certain?

        vals = pdate.qualifiers.dup
        if pdate.approximate_and_uncertain?
          @qualified = method(:approximate_and_uncertain).call
          pdate.approximate_and_uncertain_qualifiers
            .each { |val| vals.delete(val) }
        end
        return if vals.empty?

        vals.each do |val|
          next unless respond_to?(val.type)

          @qualified = method(val.type).call
        end
      end

      def qualify_set
        set_type = pdate.set_type
        return unless set_type

        meth = set_qualification_method(set_type)
        return unless respond_to?(meth, true)

        @qualified = method(meth).call
      end

      def set_qualification_method(set_type)
        :"#{set_type}_set"
      end

      def tokens
        pdate.source.sources
      end

      def translate_value
        raise NotImplementedError,
          "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
