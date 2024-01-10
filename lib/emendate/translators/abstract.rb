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
        @warnings = processed.warnings
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

      def qualify(_meth = nil)
        @qualified = base.dup
        return if pdate.certain?

        vals = pdate.certainty.dup
        if pdate.approximate_and_uncertain?
          @qualified = method(:approximate_and_uncertain).call
          %i[approximate uncertain].each{ |val| vals.delete(val) }
        end
        return if vals.empty?

        vals.each do |val|
          next unless respond_to?(val)

          @qualified = method(val).call
        end
      end

      def tokens
        pdate.source.sources
      end

      def translate_value
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
