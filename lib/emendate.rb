# frozen_string_literal: true

# std lib
require 'date'
require 'fileutils'

# external gems
require 'active_support'
require 'active_support/core_ext/object'
require 'dry-configurable'
require 'dry/monads'
require 'dry/monads/do'
require 'pry-byebug'

require 'emendate/errors'
require 'emendate/date_types/date_type'
# require 'emendate/segment/segment'

Dir.glob("#{__dir__}/**/*").sort.select{ |path| path.match?(/\.rb$/) }.each do |rbfile|
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
    setting :ambiguous_year_rollback_threshold,
            default: Date.today.year.to_s[-2..-1].to_i,
            reader: true
    setting :and_or_date_handling, default: :multi, reader: true
    setting :bce_handling, default: :precise, reader: true
    setting :before_date_treatment, default: :point, reader: true
    setting :beginning_hyphen, default: :unknown, reader: true
    setting :edtf, default: false, reader: true
    setting :ending_hyphen, default: :open, reader: true
    setting :ending_slash, default: :open, reader: true
    setting :max_output_dates, default: :all, reader: true
    setting :max_month_number_handling, default: :months, reader: true
    setting :open_unknown_end_date,
            default: '2999-12-31',
            reader: true,
            constructor: ->(value){ Date.parse(value) }
    setting :open_unknown_start_date,
            default: '1583-01-01',
            reader: true,
            constructor: ->(value){ Date.parse(value) }
    setting :pluralized_date_interpretation, default: :decade, reader: true
    setting :square_bracket_interpretation, default: :inferred_date, reader: true
    setting :dialect, default: nil, reader: true
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

  # @param string [String] original date string
  # @param target [Class] class you need input for
  # @param options [Hash]
  def prepped_for(string:, target:, options: nil)
    Emendate::Options.new(options) if options

    to_prep =  prep_steps(target)
    return string unless to_prep

    tokens = to_prep.first
                    .call(string)
                    .value!

    return tokens if to_prep.length == 1

    to_prep.shift
    to_prep.each do |step|
      tokens = step.call(tokens)
                   .value!
    end

    tokens
  end

  def parse(str, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
    pm.call
    pm.result
  end

  def process(str, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
    pm.call
    pm
  end

  def lex(str)
    prepped_for(string: str, target: Emendate::UntokenizableTagger)
  end

  def translate(str, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
    pm.call
    translator = Emendate::Translator.new(pm)
    translator.call
  end

  def tokenize(str)
    tokens = lex(str).map(&:type)
    puts "#{str}\t\t#{tokens.inspect}"
  end

  # @param strings [Array<String>]
  # @param options [Hash]
  def batch_process(strings, options = {})
    Emendate::Options.new(options) unless options.empty?
    strings.each do |str|
      pm = Emendate::ProcessingManager.call(str)
      if pm.success?
        yield pm.value!
      else
        yield pm.failure
      end
    end
  end

  # @param strings [Array<String>]
  # @param options [Hash]
  def batch_translate(strings, options = {})
    Emendate::Options.new(options) unless options.empty?
    strings.each do |str|
      pm = Emendate::ProcessingManager.call(str)
      processed = pm.success? ? pm.value! : pm.failure
      translator = Emendate::Translator.new(processed)
      yield translator.call
    end
  end

  private

  def processing_steps
    [
      Emendate::StringNormalizer,
      Emendate::Lexer,
      Emendate::UntokenizableTagger,
      Emendate::UnprocessableTagger,
      Emendate::KnownUnknownTagger,
      Emendate::TokenReplacer,
      Emendate::TokenCollapser,
      Emendate::AlphaMonthConverter,
      Emendate::OrdinalTranslator,
      Emendate::CertaintyChecker,
      Emendate::FormatStandardizer,
      Emendate::DatePartTagger,
      Emendate::DateSegmenter,
      Emendate::RangeIndicator,
      Emendate::TokenCleaner
    ].map{ |klass| [klass, ->(tokens){ klass.send(:call, tokens) }] }
      .to_h
  end

  # @param step [Class] class you are preparing input for
  def prep_steps(step)
    keys = processing_steps.keys
    target_idx = keys.find_index(step)
    return unless target_idx
    return if target_idx == 0

    keys[0..(target_idx - 1)]
  end
end
