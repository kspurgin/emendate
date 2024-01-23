# frozen_string_literal: true

require "emendate/date_types/year_month_day"
require "emendate/date_utils"
require "emendate/month_day_analyzer"
require "emendate/short_year_handler"

module Emendate
  class AllShortMdyAnalyzer
    include DateUtils

    class << self
      def call(tokens) = new(tokens).call
    end

    # @param tokens [SegmentSet] (or subclasses)
    def initialize(tokens)
      @result = Emendate::SegmentSet.new.copy(tokens)
      @numbers = [result[0], result[1], result[2]]
      @opt = Emendate.options.ambiguous_month_day_year
    end

    def call
      analyze
      result
    end

    private

    attr_reader :result, :numbers, :opt

    def analyze
      case valid_permutations.length
      when 0
        raise MonthDayYearError, numbers
      when 1
        transform_unambiguous(valid_permutations[0])
      when 2
        if valid_permutations[0][0].literal == valid_permutations[1][0].literal
          transform_ambiguous_pair(valid_permutations[0])
        else
          transform_all_ambiguous
        end
      else
        transform_all_ambiguous
      end
    end

    def valid_permutations
      numbers.permutation(3)
        .map { |per| permutation_valid?(per) }
        .compact
    end

    def permutation_valid?(per)
      Date.new(expand_year(per[0]), per[1].literal, per[2].literal)
      per
    rescue
      nil
    end

    def expand_year(n)
      Emendate::ShortYearHandler.call(n).literal
    end

    def transform_unambiguous(parts)
      transform_part(parts[0], :year)
      transform_part(parts[1], :month)
      transform_part(parts[2], :day)
    end

    def transform_ambiguous_pair(part)
      yr = transform_part(part[0], :year)

      analyzer = Emendate::MonthDayAnalyzer.call(part[1], part[2], yr)

      transform_part(analyzer.month, :month)
      transform_part(analyzer.day, :day)
      analyzer.warnings.each { |warn| result.add_warning(warn) }
    end

    def transform_all_ambiguous
      numbers.each_with_index do |part, ind|
        transform_part(part, preferred_order[ind])
      end
      parts = %i[year month day].map { |type| result.when_type(type)[0] }
      if valid_date?(*parts)
        result.add_warning("Ambiguous two-digit month/day/year treated #{opt}")
      else
        raise PreferredMdyOrderInvalidError, result.segments
      end
    end

    def transform_part(part, type)
      if type == :year
        transform_year(part)
      else
        result.replace_x_with_date_part_type(x: part, date_part_type: type)
      end
    end

    def transform_year(part)
      result.replace_x_with_new(
        x: part,
        new: Emendate::Segment.new(type: :year, literal: expand_year(part),
          sources: [part])
      )
    end

    def preferred_order
      Emendate.options.ambiguous_month_day_year
        .to_s
        .split("_")
        .map(&:to_sym)
    end
  end
end
