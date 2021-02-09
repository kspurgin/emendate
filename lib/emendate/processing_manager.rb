# frozen_string_literal: true

module Emendate
  class ProcessingManager
    include AASM
    attr_reader :orig_string, :options, :norm_string, :tokens, :orig_tokens,
      :converted_months,
      :translated_ordinals,
      :certainty_checked_whole_values,
      :exploded_uncertainty_digits,
      :standardized_formats,
      :tagged_date_parts,
      :segmented_dates,
      :errors, :warnings
    def initialize(string, options = {})
      @orig_string = string
      @options = Emendate::Options.new(options)
      @norm_string = Emendate.normalize_orig(orig_string)
      @tokens = Emendate::TokenSet.new
      @errors = []
      @warnings = []
    end

    aasm do
      state :startup, initial: true
      state :tokenized,
        :months_converted,
        :ordinals_translated,
        :whole_value_certainty_checked,
        :uncertainty_digits_exploded,
        :formats_standardized,
        :date_parts_tagged,
        :dates_segmented,
        :done, :failed

      after_all_transitions :log_status_change, :gather_warnings
      
      event :lex do
        transitions from: :startup, to: :tokenized, after: :perform_lex
      end
      event :convert_months do
        transitions from: :tokenized, to: :months_converted, after: :perform_convert_months, guard: :no_errors?
      end
      event :translate_ordinals do
        transitions from: :months_converted, to: :ordinals_translated, after: :perform_translate_ordinals, guard: :no_errors?
      end
      event :certainty_check_whole_values do
        transitions from: :ordinals_translated, to: :whole_value_certainty_checked, after: :perform_certainty_check_whole_values, guard: :no_errors?
      end
      event :explode_uncertainty_digits do
        transitions from: :whole_value_certainty_checked, to: :uncertainty_digits_exploded, after: :perform_explode_uncertainty_digits, guard: :no_errors?
      end
      event :standardize_formats do
        transitions from: :uncertainty_digits_exploded, to: :formats_standardized, after: :perform_standardize_formats, guard: :no_errors?
      end
      event :tag_date_parts do
        transitions from: :formats_standardized, to: :date_parts_tagged, after: :perform_tag_date_parts, guard: :no_errors?
      end
      event :segment_dates do
        transitions from: :date_parts_tagged, to: :dates_segmented, after: :perform_segment_dates, guard: :no_errors?
      end

      event :finalize do
        transitions from: :tokenized, to: :done, guard: :no_errors?
        transitions from: :tokenized, to: :failed, guard: :errors?
        transitions from: :months_converted, to: :done, guard: :no_errors?
        transitions from: :months_converted, to: :failed, guard: :errors?
        transitions from: :ordinals_translated, to: :done, guard: :no_errors?
        transitions from: :ordinals_translated, to: :failed, guard: :errors?
        transitions from: :whole_value_certainty_checked, to: :done, guard: :no_errors?
        transitions from: :whole_value_certainty_checked, to: :failed, guard: :errors?
        transitions from: :uncertainty_digits_exploded, to: :done, guard: :no_errors?
        transitions from: :uncertainty_digits_exploded, to: :failed, guard: :errors?
        transitions from: :formats_standardized, to: :done, guard: :no_errors?
        transitions from: :formats_standardized, to: :failed, guard: :errors?
        transitions from: :date_parts_tagged, to: :done, guard: :no_errors?
        transitions from: :date_parts_tagged, to: :failed, guard: :errors?
        transitions from: :dates_segmented, to: :done, guard: :no_errors?
        transitions from: :dates_segmented, to: :failed, guard: :errors?
      end
    end

    def process
      lex
      convert_months if may_convert_months?
      translate_ordinals if may_translate_ordinals?
      certainty_check_whole_values if may_certainty_check_whole_values?
      explode_uncertainty_digits if may_explode_uncertainty_digits?
      standardize_formats if may_standardize_formats?
      tag_date_parts if may_tag_date_parts?
      segment_dates if may_segment_dates?
      finalize
    end

    def prep_for(event)
      ready = false
      until ready
        events = aasm.events.map(&:name)
        if events.include?(event)
          ready = true
        else
          send("may_#{events[0]}?".to_sym) ? send(events[0]) : ready = true
        end
      end
      finalize
    end

    def state
      aasm.current_state
    end

    private

    def perform_lex
      l = Emendate::Lexer.new(norm_string)
      begin
        l.tokenize
      rescue Emendate::UntokenizableError => e
        errors << e
      else
        @norm_string = l.norm
        @tokens = l.tokens
        @orig_tokens = tokens.class.new.copy(tokens)
      end
    end

    def perform_convert_months
      c = Emendate::AlphaMonthConverter.new(tokens: tokens, options: options)
      c.convert
      @tokens = c.result
      @converted_months = tokens.class.new.copy(tokens)
    end

    def perform_translate_ordinals
      t = Emendate::OrdinalTranslator.new(tokens: converted_months, options: options)
      begin
        t.translate
      rescue StandardError => e
        errors << e
      else
        @tokens = t.result
        @translated_ordinals = tokens.class.new.copy(tokens)
      end
    end

    def perform_certainty_check_whole_values
      c = Emendate::CertaintyChecker.new(tokens: translated_ordinals, options: options)
      begin
        c.check
      rescue StandardError => e
        errors << e
      else
        @tokens = c.result
        @certainty_checked_whole_values = tokens.class.new.copy(tokens)
      end
    end

    def perform_explode_uncertainty_digits
      e = Emendate::UncertaintyDigitExploder.new(tokens: certainty_checked_whole_values, options: options)
      begin
        e.explode
      rescue StandardError => e
        errors << e
      else
        @tokens = e.result
        @exploded_uncertainty_digits = tokens.class.new.copy(tokens)
      end
    end

    def perform_standardize_formats
      f = Emendate::FormatStandardizer.new(tokens: tokens, options: options)
      begin
        f.standardize
      rescue StandardError => e
        errors << e
      else
        @tokens = f.result
        @standardized_formats = tokens.class.new.copy(tokens)
      end
    end

    def perform_tag_date_parts
      t = Emendate::DatePartTagger.new(tokens: standardized_formats, options: options)
      begin
        t.tag
      rescue StandardError => e
        errors << e
      else
        @tokens = t.result
        @tagged_date_parts = tokens.class.new.copy(tokens)
      end
    end

    def perform_segment_dates
      s = Emendate::DateSegmenter.new(tokens: tagged_date_parts, options: options)
      begin
        s.segment
      rescue StandardError => e
        errors << e
      else
        @tokens = s.result
        @segmented_dates = tokens.class.new.copy(tokens)
      end
    end
    
    def log_status_change
      #puts "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
    end

    def gather_warnings
      warnings << tokens.warnings unless tokens.warnings.empty?
    end

    def errors?
      errors.empty? ? false : true
    end
    
    def no_errors?
      errors.empty? ? true : false
    end
  end
end
