# frozen_string_literal: true

module Emendate
  module Translators
    # abstract class defining the interface common to all translators
    class Abstract
      attr_reader :processed, :value, :orig, :warnings
      def translate(processed)
        @processed = processed
        @orig = processed.orig_string
        @warnings = processed.warnings
        @value = translate_value
        Emendate::Translation.new(orig: orig, value: value, warnings: warnings)
      end

      private

      def qualify(meth = nil)
        return self.method(meth).call if meth
        
        return base if tokens.certain?
        return approximate_and_uncertain if tokens.approximate_and_uncertain?
        return approximate if tokens.approximate?
      end

      def tokens
        processed.tokens
      end
      
      def translate_value
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
   end
  end
end
    
