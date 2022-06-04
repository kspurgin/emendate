# frozen_string_literal: true

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

    class UnhandledPatternError < Emendate::Error
      def initialize(tokens)
        m = "Further development work is required to support: #{tokens.map(&:lexeme).join('-')}"
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

    # @param tokens [Array<Emendate::Segment>] (or subclasses)
    def initialize(tokens)
      @result = Emendate::SegmentSets::SegmentSet.new.copy(tokens)
      @numbers = [result[0], result[2], result[4]]
    end

    def call
      analyze
      result
    end

    private

    attr_reader :result, :numbers, :months, :days, :years

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
          fail(UnhandledPatternError.new(tokens))
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

    def transform_all_ambiguous
      order = Emendate.options.ambiguous_month_day_year
        .to_s
        .split('_')
        .map(&:to_sym)

      numbers.each_with_index{ |part, ind| transform_part(part, order[ind]) }
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
    end
    
    def transform_unambiguous(parts)
      transform_part(parts[0], :year)
      transform_part(parts[1], :month)
      transform_part(parts[2], :day)
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

    #       def check_days
    #   @days = numbers.map{ |t| valid_day?(t.lexeme) ? t : nil }.compact
    #   fail(MonthDayYearError.new(tokens)) if days.empty?
    # end

    # def check_months
    #   @months = numbers.map{ |t| valid_month?(t.lexeme) ? t : nil }.compact
    #   if months.empty?
    #   end

    #   def check_years
    #     @years = numbers.map{ |t| valid_year?(expanded_year(t)) ? t : nil }.compact
    #     fail(MonthDayYearError.new(numbers)) if months.empty?
    #   end

  end
end
