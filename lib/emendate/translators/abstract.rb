# frozen_string_literal: true

module Emendate
  module Translators
    # abstract class defining the interface common to all translators
    class Abstract
      attr_reader :processed, :value, :orig, :warnings
      def translate(processed)
        @processed = processed
        @orig = processed.orig_string
        @warnings = []
        @value = translate_value
        Emendate::Translation.new(orig: orig, value: value, warnings: warnings)
      end

      private

      def translate_value
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
   end
  end
end
    
