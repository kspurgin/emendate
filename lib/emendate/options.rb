# frozen_string_literal: true

module Emendate
  class UnknownOptionError < StandardError; end
  class UnknownOptionValueError < StandardError; end
  
  class Options

    attr_reader :options
    
    def initialize(opthash = {})
      if opthash.empty?
        @options = default
      else
        @options = default.merge(opthash)
        verify
      end
    end

    def list
      options.each{ |opt, val| puts "#{opt}: #{val}" }
    end

    private

    def default
      {
        # treats 2/3 as February 3
        # alternative: as_day_month would result in March 2
        ambiguous_month_day: :as_month_day,
        
        # treats 2010-12 as 2010 - 2012
        # alternative: as_month would result in December 2010
        # this option is also applied to ambiguous season/year values
        ambiguous_month_year: :as_year,

        # whether or not to expand two digit numbers that appear to be years
        # by default, will coerce 80 to 1980
        # alternative: literal would treat it as literally the year 80
        two_digit_year_handling: :coerce,

        # numbers less than this 2-digit value are treated as current century
        # numbers greater than or equal to this are treated as the previous century
        # defaults to last two digits of current year, so in 2021...
        #  by default, 21 = 1921 and 20 = 2020
        ambiguous_year_rollback_threshold: Date.today.year.to_s[-2..-1].to_i
      }
    end

    def accepted_nondefaults
      {
        ambiguous_month_day: [:as_day_month],
        ambiguous_month_year: [:as_month],
        two_digit_year_handling: [:literal]
      }
    end
    
    def method_missing(option_name)
      if options.key?(option_name)
        options[option_name]
      else
        raise Emendate::UnknownOptionError.new(option_name)
      end
    end
    
    def verify
      unknown_options = options.keys - default.keys
      unless unknown_options.empty?
        raise Emendate::UnknownOptionError.new(unknown_options.join(', '))
      end

      options.each{ |opt, value| verify_value(opt) }
    end

    def verify_value(opt)
      return unless accepted_nondefaults.key?(opt)
      value = options[opt]
      return true if value == default[opt]
      return true if accepted_nondefaults[opt].include?(value)
      allowed = [default[opt], accepted_nondefaults[opt]].flatten
      m = "#{value} is not an accepted value for the #{opt} option. Use one of the following instead: #{allowed.join(', ')}"
      raise Emendate::UnknownOptionValueError.new(m)
    end
  end
end
