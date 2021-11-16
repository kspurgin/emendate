# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

require_relative 'translation'

module Emendate
  class Translator
    attr_reader :dialect, :processed, :date_type, :tokens
    
    def initialize(processed)
      @processed = processed
      @dialect = @processed.options.target_dialect
      unless dialect
        puts "ERROR: You must pass in a `target_dialect` option when using `translate`"
        exit
      end

      @tokens = truncate_tokens
      @date_type = determine_date_type
      extend dialect_module.constantize
    end

    def translate
      unless date_type
        warn = "No date type determined for #{processed.tokens.types.join(' ')}"
        puts "WARNING: #{warn}"
        return Emendate::Translation.new(orig: processed.orig_string,
                                         value: empty_value,
                                         warnings: [warn])
      end

      translator = dialect_translator

      unless translator
        warn = "No translator exists for #{dialect_module}::#{date_type}"
        puts "WARNING: #{warn}"
        return Emendate::Translation.new(orig: processed.orig_string,
                                         value: empty_value,
                                         warnings: [warn])
      end

      translator.translate(processed)
    end

    private

    def determine_date_type
      case tokens.types.join(' ')
      when 'year_date_type'
        'Year'
      when 'yearmonth_date_type'
        'YearMonth'
      when 'range_date_type'
        'Range'
      when 'knownunknown_date_type'
        'KnownUnknown'
      else
        nil
      end
    end

    def dialect_translator
      klass = "#{dialect_module}::#{date_type}".constantize
      klass.include(dialect_module.constantize)
      klass.new
    rescue
      nil
    end

    def dialect_module
      "Emendate::Translators::#{dialect.to_s.camelize}"
    end

    def truncate_tokens
      existing = processed.tokens
      max = processed.options.max_output_dates
      return existing if max == :all

      tokens = existing.class.new.copy(existing)
      until tokens.length == max
        tokens.pop
      end
      tokens
    end
  end
end
