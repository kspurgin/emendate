# frozen_string_literal: true

module Emendate
  module Examples
    # Mixin module for Examples::Tester
    module ResultTestable
      def expected_result
        return nil unless example.testable?

        example.rows.first.send(name.to_sym)
      end

      def tested_result
        return nil unless example.testable?

        result = example.processed
          .result
          .send(name.delete_prefix("result_").to_sym)

        if result.empty?
          "na"
        else
          result.join("|")
        end
      end
    end
  end
end
