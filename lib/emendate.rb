# frozen_string_literal: true

# std lib
require 'date'
require 'fileutils'

# external gems
require 'aasm'
require 'active_support'
require 'active_support/core_ext/object'
require 'dry-configurable'

require 'emendate/error'
require 'emendate/date_types/date_type'
# require 'emendate/segment/segment'

Dir.glob("#{__dir__}/**/*").sort.select { |path| path.match?(/\.rb$/) }.each do |rbfile|
  require rbfile.delete_prefix("#{File.expand_path(__dir__)}/lib/")
end

require_relative './emendate/example_helpers'

module Emendate
  include ExampleHelpers
  extend self
  extend Dry::Configurable

  LQ = "\u201C"
  RQ = "\u201D"

  # these tokens should only appear in EDTF dates, and will switch some of the options
  #  to support assumptions about processing EDTF
  EDTF_TYPES = %i[double_dot percent tilde curly_bracket_open letter_y letter_t letter_z letter_e]

  setting :basedir, default: Gem.loaded_specs['emendate'].full_gem_path, reader: true

  setting :options, reader: true do
    # whether to set other relevant options as appropriate for parsing EDTF input
    setting :edtf, default: false, reader: true

    # treats 2/3 as February 3
    # alternative: as_day_month would result in March 2
    setting :ambiguous_month_day, default: :as_month_day, reader: true

    # treats 2010-12 as 2010 - 2012
    # alternative: as_month would result in December 2010
    # this option is also applied to ambiguous season/year values
    setting :ambiguous_month_year, default: :as_year, reader: true

    # applies to dates where range_switch == 'before' ('before 1950', 'pre-1950')
    # if :point, date_start_full and date_end_full will be the same -- the day before the date indicated
    # if :range, date_start_full will be set from :open_unknown_start_date
    setting :before_date_treatment, default: :point, reader: true

    # whether or not to expand two digit numbers that appear to be years
    # by default, will coerce 80 to 1980
    # alternative: literal would treat it as literally the year 80
    setting :two_digit_year_handling, default: :coerce, reader: true

    # numbers less than this 2-digit value are treated as current century
    # numbers greater than or equal to this are treated as the previous century
    # defaults to last two digits of current year, so in 2021...
    #  by default, 21 = 1921 and 20 = 2020
    setting :ambiguous_year_rollback_threshold, default: Date.today.year.to_s[-2..-1].to_i, reader: true

    # how to interpret square brackets around a string: as a supplied date, or EDTF
    #  "one of" set
    setting :square_bracket_interpretation, default: :inferred_date, reader: true

    # 1990s will always be interpreted as 1990-1999, but...
    # Should 1900s be interpreted as 1900-1909, or 1900-1999?
    # Should 2000s be interpreted as 2000-2009, or 2000-2999?
    # The default is to restrict to interpreting this as a decade
    # Changing to :broad will allow it to be interpreted as century or millennium
    setting :pluralized_date_interpretation, default: :decade, reader: true

    # What date should be inserted as the beginning of an open or unknown start date
    # interval?
    setting :open_unknown_start_date, default: Date.new(1583, 1, 1), reader: true

    # What date should be inserted as the beginning of an open or unknown start date
    # interval?
    setting :open_unknown_end_date, default: Date.new(2999, 12, 31), reader: true

    # How to interpret a date like: -2001
    # edtf = negative date (BCE)
    # open = open start date of interval
    # unknown = unknown start date of interval
    setting :beginning_hyphen, default: :unknown, reader: true

    # How to interpret a date like: 2001-
    # open = open close date of interval
    # unknown = unknown close date of interval
    setting :ending_hyphen, default: :open, reader: true

    # what to use as output for KnownUnknownDateType
    # orig = return the original string passed through for parsing that individual date value
    # custom = another string, to be found as value of unknown_date_output_string
    setting :unknown_date_output, default: :orig, reader: true

    # string to use when unknown_date_output: :custom
    setting :unknown_date_output_string, default: '', reader: true

    # output to use for `Emendate.translate` command
    # must be set in order to get an `Emendate::Translation`
    setting :target_dialect, default: nil, reader: true

    setting :max_output_dates, default: :all, reader: true
  end
  
  setting :examples, reader: true do
    setting :dir, default: ->{ File.join(Emendate.basedir, 'spec', 'support') }, reader: true
    setting :file_name, default: 'examples.csv', reader: true
    setting :file_path, default: ->{ "#{Emendate.examples.dir.call}/#{Emendate.examples.file_name}" }, reader: true
    setting :tests,
      default: %w[date_start_full date_end_full
         result_warnings
         translation_lyrasis_pseudo_edtf],
      reader: true
  end
  
  # str = String to process
  # sym = Symbol of aasm event for which you would use the results as input.
  # For example, running :tag_date_parts requires successful format standardization
  #   To test date part tagging, you can use the results of prep_for(str, :tag_date_parts)
  def prep_for(str, sym, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
    pm.prep_for(sym)
    pm
  end

  def parse(str, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
    pm.process
    pm.result
  end

  def process(str, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
    pm.process
    pm
  end

  def lex(str)
    lexed = Emendate::Lexer.new(Emendate.normalize_orig(str))
    lexed.tokenize
    lexed
  end

  def translate(str, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
    pm.process
    translator = Emendate::Translator.new(pm)
    translator.translate
  end

  def tokenize(str)
    tokens = lex(str).map(&:type)
    puts "#{str}\t\t#{tokens.inspect}"
  end  
end
