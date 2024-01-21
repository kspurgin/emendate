# frozen_string_literal: true

module Emendate
  module Translators
    # namespace for EDTF translators
    module Edtf
      def date
        pdate
      end

      def empty_value
        ""
      end

      def approximate
        "#{qualified}~"
      end

      def approximate_and_uncertain
        "#{qualified}%"
      end

      def uncertain
        "#{qualified}?"
      end

      def alternate_set
        "[#{qualified}]"
      end

      def inclusive_set
        "{#{qualified}}"
      end
    end
  end
end
