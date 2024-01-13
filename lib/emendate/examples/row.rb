# frozen_string_literal: true

module Emendate
  module Examples
    class Row
      def initialize(row)
        @keys = prep(row).keys
        # metaprogramming bit to create an instance variable for each column
        keys.each { |field| instance_variable_set(:"@#{field}", row[field]) }
      end

      def data_sets
        return [] if tags_data_set.blank?

        tags_data_set.split(";").sort
      end

      def date_types
        return [] if tags_date_type.blank?

        tags_date_type.split(";").sort
      end

      # type value must be: :data_sets or :date_types
      def tagged?(type:, tags:)
        all_tags = method(type).call
        return false if all_tags.empty?

        tags.all? { |tag| all_tags.any?(tag) }
      end

      def warnings
        return [] if result_warnings.blank?

        result_warnings.split(";")
      end

      def test_fingerprint
        opt = test_options || "no options"
        "#{test_string} ||| #{opt}"
      end

      def runnable_tests
        Emendate.examples.tests.map { |test| [test, send(test.to_sym)] }
          .to_h
          .compact
          .keys
      end

      def respond_to_missing?(method, *)
        keys.include?(method.to_s) || super
      end

      private

      attr_reader :keys

      # avoid manually declaring attr_reader for every column in row
      def method_missing(symbol, *args)
        instance_variable_get(:"@#{symbol}")
      rescue
        super(symbol, *args)
      end

      def prep(row)
        row.to_h
          .transform_values { |val| (val == "nilValue") ? nil : val }
          .transform_values { |val| (val == "today") ? Date.today : val }
      end

      def test_expectation?(field)
        %w[date result translation].any?(field.split("_").first)
      end
    end
  end
end
