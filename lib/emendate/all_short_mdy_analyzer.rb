# frozen_string_literal: true

require 'emendate/date_types/year_month_day'
require 'emendate/date_utils'
require 'emendate/month_day_analyzer'
require 'emendate/result_editable'
require 'emendate/short_year_handler'

module Emendate
  class AllShortMdyAnalyzer
    class MonthDayYearError < Emendate::Error
      def initialize(tokens)
        m = "Cannot determine any valid month/day/year combination for #{tokens.map(&:lexeme).join('-')}"
        super(m)
      end
    end

    class PreferredMdyOrderInvalidError < Emendate::Error
      def initialize(tokens)
        m = "Using ambiguous MDY order #{Emendate.options.ambiguous_month_day_year} results in invalid date for: #{tokens.map(&:lexeme).join('-')}"
        super(m)
      end
    end
    
    include DateUtils
    include ResultEditable

    class << self
      def call(tokens)
        self.new(tokens).call
      end
    end

    attr_reader :datetype, :warnings
    
    # @param tokens [Array<Emendate::Segment>] (or subclasses)
    def initialize(tokens)
      @result = Emendate::SegmentSets::SegmentSet.new.copy(tokens)
      @numbers = [result[0], result[2], result[4]]
      @opt = Emendate.options.ambiguous_month_day_year
      @warnings = []
    end

    def call
      analyze
      self
    end

    private

    attr_reader :result, :numbers, :opt

    def analyze
      case valid_permutations.length
      when 0
        fail(MonthDayYearError.new(numbers))  
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

    def collapse_hyphen(part)
      return part if result[-1] == part
      
      ind = result.find_index(part)
      to_collapse = [result[ind], result[ind + 1]]
      collapse_token_pair_backward(*to_collapse)
      result[ind]
    end

    def derive_datetype
      year = result.when_type(:year)[0]
      month = result.when_type(:month)[0]
      day = result.when_type(:day)[0]
      
      @datetype = Emendate::DateTypes::YearMonthDay.new(year: year.literal,
                                            month: month.literal,
                                            day: day.literal,
                                            children: [year, month, day])

    end
    
    def expand_year(n)
      Emendate::ShortYearHandler.call(n).lexeme
    end

    def permutation_valid?(per)
      yr = expand_year(per[0])
      prepped = [yr.to_i, per[1..2].map(&:literal)].flatten
      Date.new(prepped[0], prepped[1], prepped[2])
    rescue StandardError
      nil
    else
      per
    end

    def preferred_order
      Emendate.options.ambiguous_month_day_year
        .to_s
        .split('_')
        .map(&:to_sym)
    end
    
    def transform_all_ambiguous
      numbers.each_with_index{ |part, ind| transform_part(part, preferred_order[ind]) }
      parts = %i[year month day].map{ |type| result.when_type(type)[0] }

      if valid_date?(*parts)
        @warnings << "Ambiguous two-digit month/day/year treated #{opt}"
        derive_datetype
      else
        fail(PreferredMdyOrderInvalidError.new(result.segments))
      end
    end

    def transform_ambiguous_pair(part)
      yr = transform_part(part[0], :year)

      begin
        analyzer = Emendate::MonthDayAnalyzer.call(part[1], part[2], yr)
      rescue Emendate::Error => err
        raise err
      end

      transform_part(analyzer.month, :month)
      transform_part(analyzer.day, :day)
      analyzer.warnings.each{ |warn| @warnings << warn }
      derive_datetype
    end
    
    def transform_unambiguous(parts)
      transform_part(parts[0], :year)
      transform_part(parts[1], :month)
      transform_part(parts[2], :day)
      derive_datetype
    end

    def transform_part(part, type)
      collapsed = collapse_hyphen(part)
      if type == :year
        transform_year(collapsed)
      else
        replace_x_with_date_part_type(x: collapsed, date_part_type: type)
      end
    end

    def transform_year(part)
      expanded = expand_year(part)
      yr = Emendate::DatePart.new(type: :year,
                                  lexeme: expanded,
                                  literal: expanded.to_i,
                                  source_tokens: [part])
      replace_x_with_new(x: part, new: yr)
    end
    
    def valid_permutations
      numbers.permutation(3)
        .map{ |per| permutation_valid?(per) }
        .compact
    end
  end
end