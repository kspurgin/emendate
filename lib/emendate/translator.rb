# frozen_string_literal: true

require "active_support/core_ext/string/inflections"

require_relative "translation"
require_relative "translated_date"

module Emendate
  class Translator
    class << self
      def call(...)
        new(...).call
      end
    end

    # @param processed [Emendate::ProcessingManager]
    def initialize(processed)
      @dialect = Emendate.options.dialect
      unless dialect
        puts "ERROR: You must pass in a `dialect` option when using `translate`"
        exit
      end
      extend dialect_module.constantize
      @processed = processed

      @translation = Translation.new(pm: processed)
    end

    def call
      if processed.state == :final_check_failure
        return translate_failure(processed)
      end

      dates_to_map(processed.result.dates)
        .map { |pdate| translate_date(pdate) }
        .each { |result| translation.add_value(result) }

      translation
    end

    private

    attr_reader :dialect, :processed, :date_type, :tokens, :translation

    def dates_to_map(dates)
      max = Emendate.options.max_output_dates
      return dates if max == :all

      if dates.length > max
        translation.add_warning("#{dates.length} dates parsed from string. "\
                                "Only #{max} date(s) translated")
      end
      dates.first(max)
    end

    def dialect_module
      "Emendate::Translators::#{dialect.to_s.camelize}"
    end

    # @param pdate [Emendate::ParsedDate]
    def translate_date(pdate)
      translator = dialect_translator(pdate.date_type)

      if translator

        do_translation(translator, pdate)
      else
        no_translation(pdate.date_type)
      end
    end

    def dialect_translator(type_class)
      klass = "#{dialect_module}::#{type_class}".constantize
      klass.include(dialect_module.constantize)
      klass.new
    rescue
      nil
    end

    def no_translation(type_class)
      warn = "No translator exists for #{dialect_module}::#{type_class}"
      puts "WARNING: #{warn}"
      TranslatedDate.new(
        orig: processed.orig_string,
        value: empty_value,
        warnings: [warn]
      )
    end

    def do_translation(translator, pdate)
      translator.translate(processed, pdate)
    rescue => e
      TranslatedDate.new(
        orig: processed.orig_string,
        value: empty_value,
        warnings: [e.full_message]
      )
    end

    def determine_date_type
      case dialect
      when :collectionspace
        determine_indiv_date_types
      else
        determine_combined_date_type
      end
    end

    def determine_indiv_date_types
      tokens.select { |token| token.date_type? }
        .map { |datetype| datetype.class.name.split("::")[-1] }
    end

    def determine_combined_date_type
      case tokens.types.join(" ")
      when "century_date_type"
        "Century"
      when "decade_date_type"
        "Decade"
      when "year_date_type"
        "Year"
      when "yearmonth_date_type"
        "YearMonth"
      when "yearmonthday_date_type"
        "YearMonthDay"
      when "range_date_type"
        "Range"
      else
        case processed.state
        when :known_unknown_tagged_failure
          "KnownUnknown"
        end
      end
    end
  end
end
