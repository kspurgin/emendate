# frozen_string_literal: true

module Emendate
  module Translators
    # Namespace and shared methods for CollectionSpace structured date
    # XML translators
    module Collectionspace
      # These settings make the translator produce results closer to what the
      # CollectionSpace application's structured date parser would
      DIALECT_OPTIONS = {
        and_or_date_handling: :single_range,
        bce_handling: :naive,
        before_date_treatment: :point
      }
      SUFFIX = "T00:00:00.000Z"

      def date
        pdate
      end

      def preprocess
        set_bce_to_dummy if date.era == :bce
      end

      def base_value
        {
          dateDisplayDate: processed.orig_string,
          scalarValuesComputed: "false"
        }
      end

      def nil_value
        base_value
      end

      def empty_value
        base_value
      end

      def unknown_value
        base_value.merge({dateEarliestSingleCertainty: "no date"})
      end

      def computed
        case date.range_switch
        when :after
          computed_after
        when :before
          computed_before
        else
          computed_normal
        end
      end

      def computed_normal
        start_date = date.earliest
        end_date = date.latest

        base_value.merge({
          scalarValuesComputed: "true",
          dateEarliestScalarValue: "#{start_date.iso8601}#{SUFFIX}",
          dateEarliestSingleYear: start_date.year.to_s,
          dateEarliestSingleMonth: start_date.month.to_s,
          dateEarliestSingleDay: start_date.day.to_s,
          dateEarliestSingleEra: "CE",
          dateLatestScalarValue: "#{end_date.iso8601}#{SUFFIX}",
          dateLatestYear: end_date.year.to_s,
          dateLatestMonth: end_date.month.to_s,
          dateLatestDay: end_date.day.to_s,
          dateLatestEra: "CE"
        })
      end

      def computed_before
        end_date = date.latest + 1

        base_value.merge({
          scalarValuesComputed: "true",
          dateLatestScalarValue: "#{end_date + 1}#{SUFFIX}",
          dateLatestYear: end_date.year.to_s,
          dateLatestMonth: end_date.month.to_s,
          dateLatestDay: end_date.day.to_s,
          dateLatestEra: "CE",
          dateLatestCertainty: "Before"
        })
      end

      def computed_after
        start_date = date.earliest - 1
        end_date = date.latest

        base_value.merge({
          scalarValuesComputed: "true",
          dateEarliestScalarValue: "#{start_date.iso8601}#{SUFFIX}",
          dateEarliestSingleYear: start_date.year.to_s,
          dateEarliestSingleMonth: start_date.month.to_s,
          dateEarliestSingleDay: start_date.day.to_s,
          dateEarliestSingleEra: "CE",
          dateEarliestSingleCertainty: "After",
          dateLatestScalarValue: "#{end_date}#{SUFFIX}",
          dateLatestYear: end_date.year.to_s,
          dateLatestMonth: end_date.month.to_s,
          dateLatestDay: end_date.day.to_s,
          dateLatestEra: "CE",
          dateLatestCertainty: "After"
        })
      end

      def approximate_term
        lexeme = pdate.approximate_qualifiers
          .map(&:lexeme)
          .reject(&:empty?)
          .first
        return lexeme.capitalize if lexeme

        "Approximate"
      end

      def approximate
        term = approximate_term
        qualified.merge({
          dateEarliestSingleCertainty: term,
          dateLatestCertainty: term
        })
      end

      def approximate_and_uncertain
        term = "#{approximate_term} and #{uncertain_term}"
        qualified.merge({
          dateEarliestSingleCertainty: term,
          dateLatestCertainty: term
        })
      end

      def one_of_range_set
        raise NotImplementedError,
          "#{self.class} has not implemented method '#{__method__}'"
      end

      def all_of_set
        qualified.merge({dateNote: "Inclusive date"})
      end

      def one_of_set
        qualified.merge({dateNote: "Alternate date"})
      end

      def uncertain_term
        lexeme = pdate.uncertain_qualifiers
          .map(&:lexeme)
          .reject(&:empty?)
          .first
        return lexeme.capitalize if lexeme

        "Uncertain"
      end

      def uncertain
        term = uncertain_term
        qualified.merge({
          dateEarliestSingleCertainty: term,
          dateLatestCertainty: term
        })
      end

      private

      def set_bce_to_dummy
        segs = date.sources
        segs.when_type(:era_bce).each do |orig|
          ind = segs.find_index(orig)
          newseg = Emendate::Segment.new(type: :dummy_bce, sources: [orig])
          segs.fill(newseg, ind, 1)
        end
      end

      def qualify
        super

        set_bce_eras if date.source.sources.types.include?(:dummy_bce)
      end

      def set_bce_eras
        qualified[:dateLatestEra] = "BCE"
        return qualified if date.range_switch == :before

        qualified.merge!({dateEarliestSingleEra: "BCE"})
      end
    end
  end
end
