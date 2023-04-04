# frozen_string_literal: true

module Emendate
  module Translators
    # abstract class defining the interface common to all translators
    class Abstract
      # @param processed [Emendate::ProcessingManager]
      # @param pdate [Emendate::ParsedDate]
      def translate(processed, pdate)
        @processed = processed
        @pdate = pdate
        @warnings = processed.warnings
        @value = translate_value
        TranslatedDate.new(
          orig: processed.orig_string,
          value: value,
          warnings: warnings
        )
      end

      private

      attr_reader :processed, :pdate, :value, :warnings

      def qualify(meth = nil)
        return self.method(meth).call if meth

        return base if pdate.certain?
        return approximate_and_uncertain if pdate.approximate_and_uncertain?
        return approximate if pdate.approximate?
        return uncertain if pdate.uncertain?
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
