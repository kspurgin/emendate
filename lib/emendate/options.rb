# frozen_string_literal: true

module Emendate
  class UnknownOptionError < StandardError; end
  class UnknownOptionValueError < StandardError; end
  class AmbiguousYearRollbackThresholdError < StandardError
    def initialize(msg='Must be one or two digit integer')
      super
    end
  end
  class UnknownDateOutputStringError < StandardError
    def initialize(msg='Must be a String')
      super
    end
  end

  class MaxOutputDatesError < StandardError
    def initialize(msg='Must be an Integer or :all')
      super
    end
  end

  class Options

    attr_reader :options

    def initialize(opthash = {})
      if opthash.empty?
        @options = default
      else
        @options = default.merge(opthash)
        handle_edtf_shortcut
        verify
      end
    end

    def list
      options.each{ |opt, val| puts "#{opt}: #{val}" }
    end

    def merge(opthash)
      @options = options.merge(opthash)
      verify
    end

    private

    def default
      {
        # whether to set other relevant options as appropriate for parsing EDTF input
        edtf: false,
        
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
        ambiguous_year_rollback_threshold: Date.today.year.to_s[-2..-1].to_i,

        # how to interpret square brackets around a string: as a supplied date, or EDTF
        #  "one of" set
        square_bracket_interpretation: :inferred_date,

        # 1990s will always be interpreted as 1990-1999, but...
        # Should 1900s be interpreted as 1900-1909, or 1900-1999?
        # Should 2000s be interpreted as 2000-2009, or 2000-2999?
        # The default is to restrict to interpreting this as a decade
        # Changing to :broad will allow it to be interpreted as century or millennium
        pluralized_date_interpretation: :decade,

        # What date should be inserted as the beginning of an open or unknown start date
        # interval?
        open_unknown_start_date: Date.new(1, 1, 1),

        # What date should be inserted as the beginning of an open or unknown start date
        # interval?
        open_unknown_end_date: Date.new(2999, 12, 31),

        # How to interpret a date like: -2001
        # edtf = negative date (BCE)
        # open = open start date of interval
        # unknown = unknown start date of interval
        beginning_hyphen: :unknown,

        # How to interpret a date like: 2001-
        # open = open close date of interval
        # unknown = unknown close date of interval
        ending_hyphen: :open,

        # what to use as output for KnownUnknownDateType
        # orig = return the original string passed through for parsing that individual date value
        # custom = another string, to be found as value of unknown_date_output_string
        unknown_date_output: :orig,

        # string to use when unknown_date_output: :custom
        unknown_date_output_string: '',

        # output to use for `Emendate.translate` command
        # must be set in order to get an `Emendate::Translation`
        target_dialect: nil,

        max_output_dates: :all
        
      }
    end

    def accepted_nondefaults
      {
        edtf: [true],
        ambiguous_month_day: %i[as_day_month],
        ambiguous_month_year: %i[as_month],
        two_digit_year_handling: %i[literal],
        square_bracket_interpretation: %i[edtf_set],
        pluralized_date_interpretation: %i[broad],
        beginning_hyphen: %i[edtf open],
        ending_hyphen: %i[unknown],
        unknown_date_output: %i[custom],
        target_dialect: %i[lyrasis_pseudo_edtf edtf collectionspace]
      }
    end

    def handle_edtf_shortcut
      return unless @options[:edtf]

      @options[:beginning_hyphen] = :edtf
      @options[:square_bracket_interpretation] = :edtf_set
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

    def verify_accepted_nondefault(opt)
      value = options[opt]
      return true if value == default[opt]
      return true if accepted_nondefaults[opt].include?(value)

      allowed = [default[opt], accepted_nondefaults[opt]].flatten
      m = <<~MSG
      #{value} is not an accepted value for the #{opt} option. Use one of the following instead: #{allowed.join(', ')}
      MSG
      raise Emendate::UnknownOptionValueError.new(m.chomp)
    end

    def verify_ambiguous_year_rollback_threshold      
      val = @options[:ambiguous_year_rollback_threshold]
      raise Emendate::AmbiguousYearRollbackThresholdError.new unless val.is_a?(Integer)
      
      return if val.to_s.length <= 2
      
      raise Emendate::AmbiguousYearRollbackThresholdError.new
    end

    def verify_unknown_date_output_string
      val = @options[:unknown_date_output_string]
      return if val.is_a?(String)

      raise Emendate::UnknownDateOutputStringError.new
    end

    def verify_max_output_dates
      val = @options[:max_output_dates]
      return if val == :all
      return if val.is_a?(Integer)

      raise Emendate::MaxOutputDatesError.new
    end
    
    def verify_value(opt)
      verify_accepted_nondefault(opt) if accepted_nondefaults.key?(opt)

      verify_ambiguous_year_rollback_threshold if opt == :ambiguous_year_rollback_threshold
      verify_unknown_date_output_string if opt == :unknown_date_output_string
      verify_max_output_dates if opt == :max_output_dates
    end
  end
end
