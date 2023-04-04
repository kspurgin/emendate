# frozen_string_literal: true

module Emendate
  module Translators
    # namespace for EDTF translators
    module Edtf
      def date
        pdate
      end

      def empty_value
        ''
      end

      def approximate
        "#{base}~"
      end

      def approximate_and_uncertain
        "#{base}%"
      end

      def one_of_range_set
        "[#{base}]"
      end
    end
  end
end
