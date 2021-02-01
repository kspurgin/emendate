# frozen_string_literal: true

require 'emendate/date_utils'

module Emendate
  class ShortYearHandler
    include DateUtils
    attr_reader :orig, :options, :full_year, :result

    def initialize(y, options)
      @orig = y
      @options = options
      @full_year = y.literal
      analyze
      finalize
    end

    private

    def analyze
      return unless coerce?

      orig.literal < threshold ? coerce_current_century : coerce_previous_century
    end

    def coerce?
      options.two_digit_year_handling == :coerce ? true : false
    end

    def coerce_current_century
      @full_year = "#{this_century}#{orig.lexeme}".to_i
    end

    def coerce_previous_century
      @full_year = "#{previous_century}#{orig.lexeme}".to_i
    end

    def finalize
      @result = Emendate::DatePart.new(type: :year,
                                       lexeme: full_year.to_s,
                                       literal: full_year,
                                       source_tokens: [orig])
    end

    def previous_century
      Date.today.year.to_s[0, 2].to_i - 1
    end

    def this_century
      Date.today.year.to_s[0, 2].to_i
    end
    
    def threshold
      options.ambiguous_year_rollback_threshold
    end
  end
end
