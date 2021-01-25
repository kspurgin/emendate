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
        ambiguous_month_year: :as_year 
      }
    end

    def accepted_nondefaults
      {
        ambiguous_month_day: [:as_day_month],
        ambiguous_month_year: [:as_month] 
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
      value = options[opt]
      return true if value == default[opt]
      return true if accepted_nondefaults[opt].include?(value)
      allowed = [default[opt], accepted_nondefaults[opt]].flatten
      m = "#{value} is not an accepted value for the #{opt} option. Use one of the following instead: #{allowed.join(', ')}"
      raise Emendate::UnknownOptionValueError.new(m)
    end
  end
end
