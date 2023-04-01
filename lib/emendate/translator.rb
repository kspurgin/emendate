# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

require_relative 'translation'

module Emendate
  class Translator
    attr_reader :dialect, :processed, :date_type, :tokens

    # @param processed [Emendate::ProcessingManager]
    def initialize(processed)
      @processed = processed
      @dialect = Emendate.options.target_dialect
      unless dialect
        puts "ERROR: You must pass in a `target_dialect` option when using `translate`"
        exit
      end

      @tokens = truncate_tokens
      @date_type = determine_date_type
      extend dialect_module.constantize
    end

    def translate
      if processed.state == :failed
        warn = 'Cannot translate if date processing failed'
        puts "WARNING: #{warn}"
        return Emendate::Translation.new(orig: processed.orig_string,
                                         value: nil_value,
                                         warnings: [warn])
      end

      unless date_type
        warn = "Translator cannot determine a translation date type for #{processed.tokens.types.join(' ')}"
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

      begin
        translator.translate(processed)
      rescue => err
        return Emendate::Translation.new(orig: processed.orig_string,
                                         value: empty_value,
                                         warnings: [err.full_message])
      end

    end

    private

    def determine_date_type
      case tokens.types.join(' ')
      when 'century_date_type'
        'Century'
      when 'year_date_type'
        'Year'
      when 'yearmonth_date_type'
        'YearMonth'
      when 'yearmonthday_date_type'
        'YearMonthDay'
      when 'range_date_type'
        'Range'
      else
        case processed.state
        when :known_unknown_tagged_failure
          'KnownUnknown'
        else
          nil
        end
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

    def nil_value
      nil
    end

    def truncate_tokens
      existing = processed.tokens
      max = Emendate.options.max_output_dates
      return existing if max == :all

      tokens = existing.class.new.copy(existing)
      until tokens.length == max
        tokens.pop
      end
      tokens
    end
  end
end
