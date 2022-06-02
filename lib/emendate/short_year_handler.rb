# frozen_string_literal: true

require 'emendate/segment/date_part'
require 'emendate/date_utils'

module Emendate
  class ShortYearHandler
    include DateUtils

    class << self
      def call(year)
        self.new(year).call
      end
    end
    
    def initialize(year)
      @orig = year
    end

    def call
      Emendate::DatePart.new(type: :year,
                             lexeme: full_year.to_s,
                             literal: full_year,
                             source_tokens: [orig])
    end

    private

    attr_reader :orig

    def coerce?
      Emendate.options.two_digit_year_handling == :coerce
    end

    def coerce_current_century
      "#{current_century}#{orig.lexeme}".to_i
    end

    def coerce_previous_century
      "#{previous_century}#{orig.lexeme}".to_i
    end

    def full_year
      return orig.literal unless coerce?

      if orig.literal < threshold
        coerce_current_century
      else
        coerce_previous_century
      end
    end

    def previous_century
      Date.today.year.to_s[0, 2].to_i - 1
    end

    def current_century
      Date.today.year.to_s[0, 2].to_i
    end

    def threshold
      Emendate.options.ambiguous_year_rollback_threshold
    end
  end
end
