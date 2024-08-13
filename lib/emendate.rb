# frozen_string_literal: true

# std lib
require "date"
require "fileutils"

# external gems
require "active_support"
require "active_support/core_ext/object"
require "debug"
require "dry-configurable"
require "dry/monads"
require "dry/monads/do"

require "emendate/errors"

Dir.glob("#{__dir__}/**/*").sort.select do |path|
  path.match?(/\.rb$/)
end.each do |rbfile|
  require rbfile.delete_prefix("#{File.expand_path(__dir__)}/lib/")
end

require_relative "emendate/example_helpers"

module Emendate
  include ExampleHelpers
  extend self
  extend Dry::Configurable
  extend Dry::Monads[:result]

  # Steps called by {ProcessingManager}. Key is the step processing
  # class. Value is the state recorded if the step completes
  # successfully or used to indicate the step in which processing
  # failed
  #
  # Also used when running tests/examples to convert test strings into
  # segment sets appropriate for input for a given test.
  PROCESSING_STEPS = {
    Emendate::Lexer => :lexed,
    Emendate::UntokenizableTagger => :untokenizable_tagged,
    Emendate::UnprocessableTagger => :unprocessable_tagged,
    Emendate::KnownUnknownTagger => :known_unknown_tagged,
    Emendate::EdtfQualifier => :edtf_qualified,
    Emendate::TokenCollapser => :tokens_collapsed,
    Emendate::OrdinalTranslator => :ordinals_translated,
    Emendate::EdtfSetHandler => :edtf_sets_handled,
    Emendate::InferredDateHandler => :inferred_dates_handled,
    Emendate::UnstructuredCertaintyHandler => :unstructured_certainty_handled,
    Emendate::FormatStandardizer => :format_standardized,
    Emendate::DatePartTagger => :date_parts_tagged,
    Emendate::DateSegmenter => :dates_segmented,
    Emendate::RangeIndicator => :ranges_indicated,
    Emendate::TokenCleaner => :cleaned
  }

  setting :basedir, default: Gem.loaded_specs["emendate"].full_gem_path,
    reader: true

  setting :options, reader: true do
    setting :ambiguous_month_day, default: :as_month_day, reader: true
    setting :ambiguous_month_day_year, default: :month_day_year, reader: true
    setting :ambiguous_month_year, default: :as_year, reader: true
    setting :ambiguous_year_rollback_threshold,
      default: Date.today.year.to_s[-2..].to_i,
      reader: true
    setting :and_or_date_handling, default: :multi, reader: true
    setting :bce_handling, default: :precise, reader: true
    setting :before_date_treatment, default: :point, reader: true
    setting :beginning_hyphen, default: :unknown, reader: true
    setting :edtf, default: false, reader: true
    setting :ending_hyphen, default: :open, reader: true
    setting :ending_slash, default: :open, reader: true
    setting :hemisphere, default: :northern, reader: true
    setting :max_output_dates, default: 999, reader: true
    setting :max_month_number_handling, default: :months, reader: true
    setting :mismatched_bracket_handling, default: :absorb, reader: true
    setting :open_unknown_end_date,
      default: "2999-12-31",
      reader: true,
      constructor: ->(value) { Date.parse(value) }
    setting :open_unknown_start_date,
      default: "1583-01-01",
      reader: true,
      constructor: ->(value) { Date.parse(value) }
    setting :pluralized_date_interpretation, default: :decade, reader: true
    setting :square_bracket_interpretation, default: :inferred_date,
      reader: true
    setting :dialect, default: nil, reader: true
    setting :two_digit_year_handling, default: :coerce, reader: true
    setting :unknown_date_output, default: :orig, reader: true
    setting :unknown_date_output_string, default: "", reader: true
  end

  setting :examples, reader: true do
    setting :dir, default: -> {
      File.join(Emendate.basedir, "spec", "support")
    }, reader: true
    setting :file_name, default: "examples.csv", reader: true
    setting :file_path,
      default: -> {
        "#{Emendate.examples.dir.call}/#{Emendate.examples.file_name}"
      }, reader: true
    setting :tests,
      default: %w[date_start_full date_end_full date_certainty
        result_warnings
        translation_lyrasis_pseudo_edtf],
      reader: true
  end

  # @!group Common use commands for individual strings

  # Use this command to get a {Result}: parsed date data in a
  # structured format you can do useful stuff with. The intent of this
  # command is to mirror the behavior of the
  # {https://github.com/alexduryee/timetwister Timetwister} parse
  # command. It's not fully there yet, but returns something similar.
  # @param str [String]
  # @!macro optionsparam
  # @return [Emendate::Result]
  def parse(str, options = {})
    Emendate::Options.new(options) unless options.empty?
    process(str).result
  end

  # Use this command to parse a date string and convert the result into an
  # expression of the date in a given dialect.
  # @param str [String] to translate
  # @param options [Hash] of {Emendate::Options}; Indication of the dialect is
  #   required
  # @return [Emendate::Translation]
  def translate(str, options = {})
    Emendate::Options.new(options) unless options.empty?
    Emendate::Translator.call(process(str))
  end

  # @!endgroup

  # @!group Dev/debugging commands for individual strings

  # Use this command to explore how a given date string is processed, in
  # detail. Primarily used for development and debugging
  # @param str [String]
  # @!macro optionsparam
  # @return [Emendate::ProcessingManager]
  def process(str, options = {})
    Emendate::Options.new(options) unless options.empty?
    Emendate::ProcessingManager.call(str)
      .either(->(success) { success }, ->(failure) { failure })
  end

  # Use this command to quickly determine whether the date string can
  # be lexed (broken into its meaningful segments) for processing.
  # This is generally the first thing to try when adding handling for
  # a new date pattern
  # @param str [String]
  # @return [Emendate::SegmentSet] the initial {Emendate::Segment}s
  #   derived from date string
  def lex(str)
    prepped_for(string: str, target: Emendate::UntokenizableTagger)
  end

  # Get the input segments for the given target. Runs all steps prior to the
  # target.
  # @param string [String] original date string
  # @!macro [new] targetparam
  #   @param target [Class] the {Emendate::PROCESSING_STEPS processing step}
  #     to get input segments for. All steps prior to the target will be
  #     carried out, and the result that would normally be passed to the target
  #     will be returned
  # @!macro [new] optionsparam
  #   @param options [Hash] See
  #     {https://github.com/kspurgin/emendate/blob/main/docs/options.adoc
  #     options documentation}
  # @return [Emendate::SegmentSet] for all targets other than
  #   {Emendate::Lexer}, will return the result of the processing step prior to
  #   the target
  # @return [String] if target is {Emendate::Lexer}
  def prepped_for(string:, target:, options: nil)
    Emendate::Options.new(options) if options

    to_prep = prep_steps(target)
    return string unless to_prep

    lexed = to_prep.first.call(string)
    tokens = lexed.failure? ? nil : lexed.value!
    return lexed.failure unless tokens
    return tokens if to_prep.length == 1

    to_prep.shift
    to_prep.each do |step|
      result = step.call(tokens)
      tokens = result.failure? ? nil : result.value!
      return result.failure unless tokens
    end

    tokens
  end

  # A quick representation of the segment types produced by the lex command
  # @param str [String]
  # @macro optionsparam
  # @return [String] orig string, delim value, comma-separated list of the
  #   types returned by calling {#lex} on str
  def lex_inspect(str, opts = nil)
    tokens = lex(str).map(&:type)
    "#{str}\t\t#{tokens.inspect}"
  end

  # @!endgroup

  # @!group Batch processing commands, for use in scripts

  # @param strings [Array<String>]
  # @param options [Hash]
  # @yield [Emendate::ProcessingManager]
  # @return [Array<String>] original strings
  def batch_process(strings, options = {})
    Emendate::Options.new(options) unless options.empty?
    strings.each do |str|
      Emendate::ProcessingManager.call(str)
        .either(
          ->(success) { yield success },
          ->(failure) { yield failure }
        )
    end
  end

  # @param strings [Array<String>]
  # @param options [Hash]
  # @yield [Emendate::Translation]
  # @return [Array<String>] original strings
  def batch_translate(strings, verbose = false, options = {})
    Emendate::Options.new(options) unless options.empty?
    strings.each do |str|
      if verbose
        puts str
        puts "  Processing..."
      end
      pm = Emendate::ProcessingManager.call(str)
      processed = pm.success? ? pm.value! : pm.failure
      puts "  Translating..." if verbose
      translator = Emendate::Translator.new(processed)
      yield translator.call
    end
  end

  # @!endgroup

  private

  def processing_steps
    PROCESSING_STEPS.keys.map do |klass|
      [klass, ->(tokens) { klass.send(:call, tokens) }]
    end.to_h
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
