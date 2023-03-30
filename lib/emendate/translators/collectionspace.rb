# frozen_string_literal: true

module Emendate
  module Translators
    # namespace for CollectionSpace structured date XML translators
    module Collectionspace
      SUFFIX = 'T00:00:00.000Z'

      def base_value
        {
          dateDisplayDate: processed.orig_string,
          scalarValuesComputed: 'false'
        }
      end

      def date
        processed.result.dates.first
      end

      def nil_value
        base_value
      end

      def empty_value
        base_value
      end

      def computed
        start_date = Date.parse(date.date_start_full)
        end_date = Date.parse(date.date_end_full)
        base_value.merge({
          scalarValuesComputed: 'true',
          dateEarliestScalarValue: "#{date.date_start_full}#{SUFFIX}",
          dateEarliestSingleYear: start_date.year.to_s,
          dateEarliestSingleMonth: start_date.month.to_s,
          dateEarliestSingleDay: start_date.day.to_s,
          dateEarliestSingleEra: 'CE',
          dateLatestScalarValue: "#{date.date_end_full}#{SUFFIX}",
          dateLatestYear: end_date.year.to_s,
          dateLatestMonth: end_date.month.to_s,
          dateLatestDay: end_date.day.to_s,
          dateLatestEra: 'CE'
        })
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
