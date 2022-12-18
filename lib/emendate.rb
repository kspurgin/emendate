# frozen_string_literal: true

# std lib
require 'date'
require 'fileutils'

# external gems
require 'aasm'
require 'active_support'
require 'active_support/core_ext/object'
require 'dry-configurable'
require 'dry/monads'
require 'dry/monads/do'

require 'emendate/errors'
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
  extend Dry::Monads[:result]

  LQ = "\u201C"
  RQ = "\u201D"

  # these tokens should only appear in EDTF dates, and will switch some of the options
  #  to support assumptions about processing EDTF
  EDTF_TYPES = %i[double_dot percent tilde curly_bracket_open letter_y letter_t letter_z letter_e]

  setting :basedir, default: Gem.loaded_specs['emendate'].full_gem_path, reader: true

  setting :options, reader: true do
    setting :ambiguous_month_day, default: :as_month_day, reader: true
    setting :ambiguous_month_day_year, default: :month_day_year, reader: true
    setting :ambiguous_month_year, default: :as_year, reader: true
    setting :ambiguous_year_rollback_threshold, default: Date.today.year.to_s[-2..-1].to_i, reader: true
    setting :before_date_treatment, default: :point, reader: true
    setting :beginning_hyphen, default: :unknown, reader: true
    setting :edtf, default: false, reader: true
    setting :ending_hyphen, default: :open, reader: true
    setting :max_output_dates, default: :all, reader: true
    setting :max_month_number_handling, default: :months, reader: true
    setting :open_unknown_end_date, default: Date.new(2999, 12, 31), reader: true
    setting :open_unknown_start_date, default: Date.new(1583, 1, 1), reader: true
    setting :pluralized_date_interpretation, default: :decade, reader: true
    setting :square_bracket_interpretation, default: :inferred_date, reader: true
    setting :target_dialect, default: nil, reader: true
    setting :two_digit_year_handling, default: :coerce, reader: true
    setting :unknown_date_output, default: :orig, reader: true
    setting :unknown_date_output_string, default: '', reader: true
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

  # @param orig [String]
  # @return [String]
  def normalize_orig(orig)
    orig.downcase.sub('[?]', '?')
      .sub('(?)', '?')
      .sub(/^c([^a-z])/, 'circa\1') # initial c followed by non-letter
      .gsub(/b\.?c\.?(e\.?|)/, 'bce') # cleanup bc, bce
      .gsub(/(a\.?d\.?|c\.?e\.?)/, 'ce') # cleanup ad, ce
      .gsub(/b\.?p\.?/, 'bp') # cleanup bp
      .sub(/^n\.? ?d\.?$/, 'nodate') # cleanup nd
      .sub(/^ *not dated *$/, 'notdated') # cleanup not dated
      .sub(/^ *unkn?\.? *$/, 'unk') # cleanup unk.
      .sub(/^ *date unknown?\.? *$/, 'dateunknown')
      .sub(/^ *unknown date?\.? *$/, 'unknowndate')
      .sub(/(st|nd|rd|th) c\.?$/, '\1 century') # ending c after ordinal
  end

  # @param orig [String]
  # @return [String]
  def normalize(orig)
    result = orig.downcase.sub('[?]', '?')
      .sub('(?)', '?')
      .sub(/^c([^a-z])/, 'circa\1') # initial c followed by non-letter
      .gsub(/b\.?c\.?(e\.?|)/, 'bce') # cleanup bc, bce
      .gsub(/(a\.?d\.?|c\.?e\.?)/, 'ce') # cleanup ad, ce
      .gsub(/b\.?p\.?/, 'bp') # cleanup bp
      .sub(/^n\.? ?d\.?$/, 'nodate') # cleanup nd
      .sub(/^ *not dated *$/, 'notdated') # cleanup not dated
      .sub(/^ *unkn?\.? *$/, 'unk') # cleanup unk.
      .sub(/^ *date unknown?\.? *$/, 'dateunknown')
      .sub(/^ *unknown date?\.? *$/, 'unknowndate')
      .sub(/(st|nd|rd|th) c\.?$/, '\1 century') # ending c after ordinal
  rescue StandardError => err
    Failure(err)
  else
    Success(result)
  end

  # str = String to process
  # sym = Symbol of aasm event for which you would use the results as input.
  # For example, running :tag_date_parts requires successful format standardization
  #   To test date part tagging, you can use the results of prep_for(str, :tag_date_parts)
  def prep_for(str, sym, options = {})
    pm = Emendate::OldProcessingManager.new(str, options)
    pm.prep_for(sym)
    pm
  end

  def parse(str, options = {})
    pm = Emendate::OldProcessingManager.new(str, options)
    pm.process
    pm.result
  end

  def process(str, options = {})
    pm = Emendate::OldProcessingManager.new(str, options)
    pm.process
    pm
  end

  def lex(str)
    lexed = Emendate::OldLexer.new(Emendate.normalize_orig(str))
    lexed.tokenize
    lexed
  end

  def translate(str, options = {})
    pm = Emendate::OldProcessingManager.new(str, options)
    pm.process
    translator = Emendate::Translator.new(pm)
    translator.translate
  end

  def tokenize(str)
    tokens = lex(str).map(&:type)
    puts "#{str}\t\t#{tokens.inspect}"
  end
end
