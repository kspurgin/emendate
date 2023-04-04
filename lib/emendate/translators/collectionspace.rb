# frozen_string_literal: true

module Emendate
  module Translators
    # namespace for CollectionSpace structured date XML translators
    module Collectionspace
      SUFFIX = 'T00:00:00.000Z'

      def self.extended(mod)
        Emendate.config.options.bce_handling = :naive
        Emendate.config.options.before_date_treatment = :range
      end

      def base_value
        {
          dateDisplayDate: processed.orig_string,
          scalarValuesComputed: 'false'
        }
      end

      def date
        pdate
      end

      def nil_value
        base_value
      end

      def empty_value
        base_value
      end

      def unknown_value
        base_value.merge({dateEarliestSingleCertainty: 'no date'})
      end

      def computed
        case date.range_switch
        when 'after'
          # not yet implemented
        when 'before'
          computed_before
        else
          computed_normal
        end
      end

      def computed_normal
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

      def computed_before
        end_date = Date.parse(date.date_end_full) + 1

        base_value.merge({
          scalarValuesComputed: 'true',
          dateLatestScalarValue: "#{end_date}#{SUFFIX}",
          dateLatestYear: end_date.year.to_s,
          dateLatestMonth: end_date.month.to_s,
          dateLatestDay: end_date.day.to_s,
          dateLatestEra: 'CE',
          dateLatestCertainty: 'Before'
        })
      end

      def approximate
        lexed = processed.history[:lexed]
        types = lexed.types
        if types.any?(:about)
          computed.merge({
              dateEarliestSingleCertainty: 'about',
              dateLatestCertainty: 'about'
            })
        elsif types.any?(:approximate)
          computed.merge({
            dateEarliestSingleCertainty: 'Approximate',
            dateLatestCertainty: 'Approximate'
          })
        elsif types.any?(:circa)
          computed.merge({
            dateEarliestSingleCertainty: 'Circa',
            dateLatestCertainty: 'Circa'
          })
        end
      end

      def approximate_and_uncertain
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def one_of_range_set
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def all_of_set
        {dateNote: 'Inclusive date'}
      end

      def one_of_set
        {dateNote: 'Alternate date'}
      end

      def uncertain
        computed.merge({
          dateEarliestSingleCertainty: 'Possibly',
          dateLatestCertainty: 'Possibly'
        })
      end
    end
  end
end
