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
      if processed.state == :final_check_failed
        return translate_failure(processed)
      end

      processed.result
        .dates
        .map { |pdate| translate_date(pdate) }
        .each { |result| translation.add_value(result) }

      translation
    end

    private

    attr_reader :dialect, :processed, :date_type, :tokens, :translation

    def dialect_module
      "Emendate::Translators::#{dialect.to_s.camelize}"
    end

    def translate_failure(_failure)
      type = "Error"
      translator = dialect_translator(type)

      result = if translator
        do_translation(translator, nil)
      else
        no_translation(type)
      end
      translation.add_value(result)
      translation
    end

    # def truncate_tokens
    #   existing = processed.tokens
    #   max = Emendate.options.max_output_dates
    #   return existing if max == :all

    #   tokens = existing.class.new.copy(existing)
    #   until tokens.length == max
    #     tokens.pop
    #   end
    #   tokens
    # end

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
